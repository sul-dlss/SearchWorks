# frozen_string_literal: true

require 'json'

module Chat
  # Executes model-requested tools and returns messages suitable for the next completion.
  class ToolCallExecutor
    AVAILABILITY_TOOL = SearchworksMcp::Tools::GET_AVAILABILITY[:name]

    STATUS_MESSAGES = {
      'catalog_search_tool' => 'Searching the catalog…',
      'article_search_tool' => 'Searching articles…',
      'get_catalog_record' => 'Reading the catalog record…',
      'get_article' => 'Reading the article record…',
      'get_availability' => 'Checking availability…'
    }.freeze

    def initialize(tool_runner:, source_collection:, result_bounder: ToolResultBounder.new)
      @tool_runner = tool_runner
      @source_collection = source_collection
      @result_bounder = result_bounder
      @call_count = 0
    end

    delegate :definitions, to: :@tool_runner

    def limit_reached?
      @call_count >= Rails.configuration.x.chat.max_tool_calls
    end

    # @yield [event, data] browser-facing events: status, availability, and tool_call
    # @return [Array<Hash>] tool messages for the next completion
    def execute(tool_calls, &)
      tool_calls.map do |tool_call|
        message = if limit_reached?
                    limit_message(tool_call)
                  else
                    execute_tool_call(tool_call, &)
                  end
        yield 'tool_call', id: tool_call['id'], name: tool_call.dig('function', 'name'),
                           arguments: tool_call.dig('function', 'arguments'), result: message['content']
        message
      end
    end

    private

    def execute_tool_call(tool_call)
      @call_count += 1
      name = tool_call.dig('function', 'name')
      yield 'status', message: STATUS_MESSAGES.fetch(name, 'Searching SearchWorks…')
      result = call_tool(name, tool_call.dig('function', 'arguments'))
      unless result[:error]
        @source_collection.add(result[:structured_content])
        yield 'availability', availability_event(result[:structured_content]) if name == AVAILABILITY_TOOL
      end
      {
        'role' => 'tool',
        'tool_call_id' => tool_call['id'],
        'content' => @result_bounder.call(result)
      }
    end

    # The tool's own structured content, which the browser renders as a card. It carries no title,
    # so the title comes from the search or record result the model looked it up from.
    def availability_event(content)
      content = content.to_h.deep_symbolize_keys
      content.merge(title: @source_collection.title_for(content[:url])).compact
    end

    def limit_message(tool_call)
      {
        'role' => 'tool',
        'tool_call_id' => tool_call['id'],
        'content' => 'The tool-call limit has been reached. Use the evidence already returned.'
      }
    end

    def call_tool(name, raw_arguments)
      arguments = JSON.parse(raw_arguments.presence || '{}')
      raise JSON::ParserError, 'arguments must be a JSON object' unless arguments.is_a?(Hash)

      @tool_runner.call(name:, arguments:)
    rescue JSON::ParserError => e
      { text: "Invalid tool arguments: #{e.message}", structured_content: { error: e.message }, error: true }
    end
  end
end
