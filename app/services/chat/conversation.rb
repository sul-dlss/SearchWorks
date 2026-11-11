# frozen_string_literal: true

module Chat
  # Runs the model/tool loop for one chat turn and emits browser-facing server-sent events:
  #
  # - status: progress text while tools run
  # - delta: answer text as it streams; reset: discard the text streamed so far
  # - tool_call: a tool's name, arguments, and the result text the model saw
  # - availability: a get_availability result, rendered as a card
  # - sources: the verified records the answer may link to
  # - notice: a non-fatal message to show with the answer
  # - error: the turn failed; done: the turn finished
  class Conversation
    DISCONNECT_ERRORS = [IOError, Errno::EPIPE, Errno::ECONNRESET].freeze

    InvalidMessages = MessageHistory::InvalidMessages

    # @param controller [ActionController::Base, nil] the requesting controller, for Blacklight search state
    # @param eds_guest [Boolean] whether article tools query EDS as a guest
    def initialize(messages:, controller: nil, eds_guest: true, completion_request_factory: nil, tool_runner: nil)
      @history = MessageHistory.new(messages)
      @completion_request_factory = completion_request_factory || LiteLlmCompletionRequest.method(:new)
      @sources = SourceCollection.new
      @tool_call_executor = ToolCallExecutor.new(
        tool_runner: tool_runner || ToolRunner.new(controller:, eds_guest:),
        source_collection: @sources
      )
    end

    def each_event
      Enumerator.new do |stream|
        run { |event, data| stream << encode_event(event, data) }
      rescue StandardError => e
        report_failure(stream, e)
      end
    end

    # Runs the turn without streaming, for evaluations.
    # @yield [event, data] each event as it happens
    def run(&)
      messages = @history.with_system_prompt

      Rails.configuration.x.chat.max_tool_rounds.times do
        completion, streamed_content = stream_completion(messages, tools: @tool_call_executor.definitions, &)
        return incomplete(completion, streamed_content:, &) unless completion.complete?
        return finish(completion, &) if completion.tool_calls.empty?

        yield 'reset', {} if streamed_content.present?
        messages << completion.message
        messages.concat(@tool_call_executor.execute(completion.tool_calls, &))
        break if @tool_call_executor.limit_reached?
      end

      final_answer(messages, &)
    end

    private

    # Asks for an answer from the evidence gathered once the tool budget is spent.
    def final_answer(messages, &)
      messages << {
        'role' => 'system',
        'content' => 'Stop searching and answer now using only the evidence already returned. If it is insufficient, say so.'
      }
      2.times do |attempt|
        messages << { 'role' => 'system', 'content' => 'Return a final answer as plain response text now. Do not call a tool.' } if attempt.positive?
        completion, streamed_content = stream_completion(messages, tools: @tool_call_executor.definitions, tool_choice: 'none', &)
        return incomplete(completion, streamed_content:, &) unless completion.complete?
        return finish(completion, &) if completion.tool_calls.empty? && streamed_content.present?

        yield 'reset', {} if streamed_content.present?
      end

      Rails.logger.warn('Chat response contained no final answer text')
      yield 'error', reason: 'empty_response', message: 'The chat service could not produce an answer. Please try again.'
    end

    def stream_completion(messages, tools:, tool_choice: nil)
      streamed_content = +''
      request = @completion_request_factory.call(messages:, tools:, tool_choice:)
      completion = request.stream_completion do |delta|
        streamed_content << delta
        yield 'delta', content: delta
      end
      [completion, streamed_content]
    end

    def finish(completion, &)
      finalize_answer(completion.message['content'].to_s, &)
      yield 'done', {}
    end

    # Links bare mentions of verified record titles, and tells the browser which URLs are verified
    # so it can drop any other links the model wrote.
    def finalize_answer(answer)
      sources = @sources.to_a
      linked_answer = CitationLinker.new(sources:).call(answer)
      yield 'sources', sources: sources
      return if linked_answer == answer

      yield 'reset', {}
      yield 'delta', content: linked_answer
    end

    def incomplete(completion, streamed_content:, &)
      Rails.logger.warn("Chat response incomplete: finish_reason=#{completion.finish_reason.inspect}")
      if completion.length_limited? && streamed_content.present?
        finalize_answer(streamed_content, &)
        yield 'notice', message: 'This response reached its length limit and may be incomplete. Please retry or ask a narrower question.'
        yield 'done', {}
        return
      end

      if completion.length_limited?
        yield 'error', reason: 'output_length_limit',
                       message: 'The response reached its length limit before it finished. Please retry or ask a narrower question.'
      else
        yield 'error', reason: 'incomplete_response', message: 'The response could not be completed. Please try again.'
      end
    end

    # The browser is written to from inside this enumerator, so a hangup surfaces as an exception
    # from whatever the loop happened to be doing. There is nobody left to tell in that case.
    def report_failure(stream, error)
      if client_disconnected?(error)
        Rails.logger.info("Chat client disconnected mid-stream: #{error.class}: #{error.message}")
        return
      end

      Rails.logger.error("Chat request failed: #{error.class}: #{error.message}")
      Honeybadger.notify(error)
      stream << encode_event('error', failure_for(error))
    rescue StandardError => e
      Rails.logger.info("Chat client disconnected before the error event was sent: #{e.class}: #{e.message}")
    end

    def client_disconnected?(error)
      # Puma::ConnectionError is not necessarily loaded when this class is, so it is resolved here.
      return true if defined?(Puma::ConnectionError) && error.is_a?(Puma::ConnectionError)

      DISCONNECT_ERRORS.any? { |disconnect_error| error.is_a?(disconnect_error) }
    end

    def failure_for(error)
      if error.is_a?(Net::OpenTimeout) || error.is_a?(Net::ReadTimeout)
        { reason: 'timeout',
          message: 'The chat service timed out before it could finish. Please try again, or ask a narrower question.' }
      else
        { reason: 'service_error', message: 'The chat service could not complete that request. Please try again.' }
      end
    end

    def encode_event(event, data)
      "event: #{event}\ndata: #{JSON.generate(data)}\n\n"
    end
  end
end
