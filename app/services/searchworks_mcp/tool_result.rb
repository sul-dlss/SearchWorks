# frozen_string_literal: true

module SearchworksMcp
  # Builds the { text:, structured_content:, error: } hash every tool returns, which
  # McpController turns into an MCP::Tool::Response.
  module ToolResult
    module_function

    def success(text, structured_content)
      { text: text, structured_content: structured_content }
    end

    # @param error [String] short machine-readable error for structured content (defaults to text)
    def failure(text, error: text)
      { text: text, structured_content: { error: error }, error: true }
    end

    # Reports an unexpected exception and returns a failure that doesn't leak its details.
    def internal_error(exception, public_message:)
      SearchworksMcp.report_exception(exception)
      failure(public_message)
    end
  end
end
