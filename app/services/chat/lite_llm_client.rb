# frozen_string_literal: true

require "net/http"

module Chat
  # Sends authenticated HTTP requests to the configured LiteLLM proxy.
  class LiteLlmClient
    def initialize(api_base: ENV.fetch("LITELLM_API_BASE", nil), api_key: ENV.fetch("LITELLM_API_KEY", nil))
      raise "LITELLM_API_BASE environment variable is not set" if api_base.blank?
      raise "LITELLM_API_KEY environment variable is not set" if api_key.blank?

      api_base = api_base.chomp("/")
      @api_base = api_base.end_with?("/v1") ? api_base : "#{api_base}/v1"
      @api_key = api_key
    end

    def post(path, body:, headers: {}, &)
      uri = URI("#{@api_base}/#{path.delete_prefix('/')}")
      request = Net::HTTP::Post.new(
        uri,
        {
          "Authorization" => "Bearer #{@api_key}",
          "Content-Type" => "application/json"
        }.merge(headers)
      )
      request.body = body

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = 10
      http.read_timeout = 120
      http.request(request, &)
    end
  end
end
