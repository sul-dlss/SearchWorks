# frozen_string_literal: true

require "json"
require "net/http"

module Chat
  # Streams OpenAI-compatible chat completions from the configured LiteLLM proxy.
  class LiteLlmCompletionRequest # rubocop:disable Metrics/ClassLength
    INSTRUMENTATION_EVENT = "request.litellm"
    MAX_ERROR_DETAIL_CHARACTERS = 2_000

    class RequestError < StandardError; end

    Completion = Data.define(:message, :tool_calls, :finish_reason) do
      def complete?
        finish_reason.blank? || %w[stop tool_calls function_call].include?(finish_reason.downcase)
      end

      def length_limited?
        %w[length max_tokens].include?(finish_reason.to_s.downcase)
      end
    end

    def initialize(messages:, tools: nil, tool_choice: nil, reasoning_effort: nil, max_tokens: nil, # rubocop:disable Metrics/ParameterLists
                   client: LiteLlmClient.new)
      @messages = messages
      @tools = tools
      @tool_choice = tool_choice
      @reasoning_effort = reasoning_effort
      @max_tokens = max_tokens
      @client = client
    end

    def stream_completion
      model = chat_model

      instrument_request(model) do |payload|
        perform_request(model, payload) do |data|
          yield data if block_given?
        end
      end
    end

    private

    def chat_model
      model = ENV.fetch("LITELLM_CHAT_MODEL", nil)
      raise "LITELLM_CHAT_MODEL environment variable is not set" if model.blank?

      model
    end

    def request_body(model)
      {
        model:,
        messages: @messages,
        tools: @tools.presence,
        tool_choice: @tool_choice || (@tools.present? ? "auto" : nil),
        reasoning_effort: @reasoning_effort || Rails.configuration.x.chat.reasoning_effort.presence,
        max_tokens: @max_tokens || Rails.configuration.x.chat.max_output_tokens,
        stream: true,
        stream_options: { include_usage: true }
      }.compact.to_json
    end

    def perform_request(model, payload, &)
      @started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      content = +""
      tool_calls = {}
      parser = EventStreamParser.new

      @client.post(
        "chat/completions",
        body: request_body(model),
        headers: { "Accept" => "text/event-stream" }
      ) do |response|
        payload[:http_status] = response.code.to_i
        payload[:request_id] = response["x-litellm-call-id"] || response["x-request-id"]
        raise_request_error(response) unless response.is_a?(Net::HTTPSuccess)

        response.read_body do |chunk|
          parser.feed(chunk) do |event_data|
            process_event(event_data, content, tool_calls, payload, &)
          end
        end
        parser.finish do |event_data|
          process_event(event_data, content, tool_calls, payload, &)
        end
      end
      raise RequestError, "LiteLLM stream ended before its done event" unless payload[:stream_complete]

      calls = tool_calls.sort_by { |index, _call| index }.map do |index, call|
        call["id"] ||= "call_#{index}"
        call
      end
      message = { "role" => "assistant", "content" => content.presence }
      message["tool_calls"] = calls if calls.any?
      Completion.new(message:, tool_calls: calls, finish_reason: payload[:finish_reason])
    end

    def raise_request_error(response)
      body = response.body.to_s
      detail = JSON.parse(body).dig("error", "message")
      detail = body if detail.blank?
      detail = detail.to_s.truncate(MAX_ERROR_DETAIL_CHARACTERS)
      suffix = detail.present? ? ": #{detail}" : ""
      raise RequestError, "LiteLLM chat request failed (#{response.code})#{suffix}"
    rescue JSON::ParserError
      detail = body.truncate(MAX_ERROR_DETAIL_CHARACTERS)
      raise RequestError, "LiteLLM chat request failed (#{response.code}): #{detail}"
    end

    def process_event(event_data, content, tool_calls, payload)
      if event_data == "[DONE]"
        payload[:stream_complete] = true
        return
      end

      event = JSON.parse(event_data)
      payload[:response_id] ||= event["id"]
      add_usage(payload, event["usage"])
      payload[:finish_reason] = event.dig("choices", 0, "finish_reason") || payload[:finish_reason]
      delta = event.dig("choices", 0, "delta") || {}

      if delta["content"].present?
        payload[:first_content_token_ms] ||= elapsed_ms
        content << delta["content"]
        yield delta["content"]
      end

      Array(delta["tool_calls"]).each do |fragment|
        call = (tool_calls[fragment.fetch("index")] ||= {
          "id" => nil,
          "type" => "function",
          "function" => { "name" => +"", "arguments" => +"" }
        })
        call["id"] ||= fragment["id"]
        function = fragment["function"] || {}
        call["function"]["name"] << function["name"] if function["name"]
        call["function"]["arguments"] << function["arguments"] if function["arguments"]
      end
    rescue JSON::ParserError => e
      raise "LiteLLM returned an invalid streaming event: #{e.message}"
    end

    # Milliseconds since the HTTP request began. Compared against the event's total duration this
    # separates time the model spent before emitting prose (connection, queueing, reasoning tokens)
    # from time spent streaming it.
    def elapsed_ms
      ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - @started_at) * 1_000).round(1)
    end

    def add_usage(payload, usage)
      return unless usage

      payload[:prompt_tokens] = usage["prompt_tokens"] if usage["prompt_tokens"]
      payload[:completion_tokens] = usage["completion_tokens"] if usage["completion_tokens"]
      payload[:total_tokens] = usage["total_tokens"] if usage["total_tokens"]
    end

    def instrument_request(model, &)
      ActiveSupport::Notifications.instrument(
        INSTRUMENTATION_EVENT,
        model: model,
        operation: "chat.completions",
        input_count: @messages.length,
        input_characters: @messages.sum { |message| message["content"].to_s.length },
        instruction_present: @messages.any? { |message| message["role"] == "system" },
        &
      )
    end

    # Incrementally parses data fields from a server-sent event stream.
    class EventStreamParser
      def initialize
        @buffer = +""
        @data_lines = []
      end

      def feed(chunk, &)
        @buffer << chunk
        consume_lines(&)
      end

      def finish(&)
        consume_line(@buffer.delete_suffix("\r"), &) if @buffer.present?
        @buffer.clear
        dispatch(&)
      end

      private

      def consume_lines(&)
        while (newline = @buffer.index("\n"))
          line = @buffer.slice!(0..newline).delete_suffix("\n").delete_suffix("\r")
          consume_line(line, &)
        end
      end

      def consume_line(line, &)
        if line.empty?
          dispatch(&)
        elsif line.start_with?("data:")
          @data_lines << line.delete_prefix("data:").delete_prefix(" ")
        end
      end

      def dispatch
        return if @data_lines.empty?

        data = @data_lines.join("\n")
        @data_lines.clear
        yield data
      end
    end
  end
end
