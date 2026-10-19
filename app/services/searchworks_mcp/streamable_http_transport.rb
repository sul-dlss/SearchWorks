# frozen_string_literal: true

module SearchworksMcp
  # Adds the MCP requirement that request IDs must be strings or integers.
  # The upstream JSON-RPC handler treats an explicit null ID as a notification.
  class StreamableHttpTransport < MCP::Server::Transports::StreamableHTTPTransport
    private

    def validate_modern_headers(request, body, header_version)
      return invalid_request_response("Invalid Request: request id must not be null") if body.key?(:id) && body[:id].nil?

      super
    end
  end
end
