# frozen_string_literal: true

require 'mcp'

module Chat
  # Validates and executes the SearchWorks MCP tools in-process on behalf of the chat model.
  class ToolRunner
    START_INSTRUMENTATION_EVENT = 'start.mcp_tool'
    INSTRUMENTATION_EVENT = 'call.mcp_tool'
    # Results recorded per call in the instrumentation payload, for quality review in the logs.
    LOGGED_RESULT_LIMIT = 10

    MODEL_SCHEMA_KEYS = %w[
      type properties required items enum description minimum maximum minLength maxLength minItems maxItems
    ].freeze

    # @param controller [ActionController::Base, nil] the requesting controller, for Blacklight search state
    # @param eds_guest [Boolean] whether article tools query EDS as a guest
    def initialize(controller: nil, eds_guest: true)
      @controller = controller
      @eds_guest = eds_guest
    end

    # Tool definitions in the OpenAI-compatible function format LiteLLM accepts.
    def definitions
      SearchworksMcp::Tools::ALL.map do |definition|
        {
          type: 'function',
          function: {
            name: definition[:name],
            description: definition[:description],
            parameters: model_compatible_schema(SearchworksMcp::Tools.resolve_schema(definition[:input_schema]))
                        .merge(type: 'object')
          }
        }
      end
    end

    # @param arguments [Hash] arguments as the model supplied them
    # @return [Hash] { text:, structured_content:, error: }
    def call(name:, arguments:)
      definition = SearchworksMcp::Tools.find(name)
      return error_result("Tool not found: #{name}") unless definition

      schema = MCP::Tool::InputSchema.new(SearchworksMcp::Tools.resolve_schema(definition[:input_schema]))
      schema.validate_arguments(arguments)
      notify_tool_started(name, arguments)

      instrument(name, arguments) do |payload|
        result = SearchworksMcp::Tools.invoke(name, arguments.deep_symbolize_keys, controller: @controller, eds_guest: @eds_guest)
        payload[:results] = logged_results(result)
        payload[:tool_error] = true if result[:error]
        result
      end
    rescue MCP::Tool::InputSchema::ValidationError => e
      error_result(e.message)
    rescue StandardError => e
      SearchworksMcp.report_exception(e, context: { tool_name: name })
      error_result('The tool could not complete that request.')
    end

    private

    # MCP schemas remain authoritative for validation. The copy sent to the model uses the JSON
    # Schema subset accepted across LiteLLM-backed providers.
    def model_compatible_schema(value, property_map: false)
      case value
      when Hash
        value.each_with_object({}) do |(key, child), compatible|
          next unless property_map || MODEL_SCHEMA_KEYS.include?(key.to_s)

          compatible[key] = model_compatible_schema(child, property_map: key.to_s == 'properties')
        end
      when Array
        value.map { |child| model_compatible_schema(child) }
      else
        value
      end
    end

    def logged_results(result)
      content = result[:structured_content]
      return unless content.is_a?(Hash)

      records = content[:results] || [content.slice(:id, :title)]
      Array(records).first(LOGGED_RESULT_LIMIT).map { |record| record.to_h.slice(:id, :title) }.compact_blank
    end

    def instrument(name, arguments, &)
      ActiveSupport::Notifications.instrument(INSTRUMENTATION_EVENT, **event_payload(name, arguments), &)
    end

    def notify_tool_started(name, arguments)
      ActiveSupport::Notifications.instrument(START_INSTRUMENTATION_EVENT, **event_payload(name, arguments))
    end

    def event_payload(name, arguments)
      { tool_name: name, input: arguments.deep_dup, request_id: @controller&.request&.uuid }
    end

    def error_result(message)
      { text: message, structured_content: { error: message }, error: true }
    end
  end
end
