# frozen_string_literal: true

require 'json'
require 'net/http'

# Creates Gemini Embedding 2 vectors through an OpenAI-compatible LiteLLM
# endpoint.
class GeminiEmbedding
  DEFAULT_QUERY_INSTRUCTION = 'search result'
  DIMENSIONS = 768
  INSTRUMENTATION_EVENT = 'request.litellm'
  MODEL = 'gemini-embedding-2'

  def self.model
    ENV.fetch('LITELLM_EMBEDDING_MODEL', MODEL)
  end

  def embedding(input:, instruction: nil)
    return [] if input.empty?

    api_base = ENV.fetch('LITELLM_API_BASE', 'https://dlss-aigateway-prod.stanford.edu/v1/')
    api_key = ENV.fetch('LITELLM_API_KEY', nil)
    raise 'LITELLM_API_BASE environment variable is not set' if api_base.blank?
    raise 'LITELLM_API_KEY environment variable is not set' if api_key.blank?

    uri = URI("#{normalized_api_base(api_base)}/embeddings")
    model = self.class.model
    request_input = input.map { |text| instruction ? "task: #{instruction} | query: #{text}" : text }
    request = Net::HTTP::Post.new(
      uri,
      'Authorization' => "Bearer #{api_key}",
      'Content-Type' => 'application/json'
    )
    request.body = {
      model:,
      input: request_input,
      dimensions: DIMENSIONS
    }.to_json

    instrument_request(model, request_input, instruction.present?) do |payload|
      response = http_client(uri).request(request)
      payload[:http_status] = response.code.to_i
      payload[:request_id] = response['x-litellm-call-id'] || response['x-request-id']

      raise "LiteLLM embedding request failed (#{response.code}): #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      parsed_response = JSON.parse(response.body)
      add_response_metadata(payload, parsed_response)
      embeddings_from(parsed_response, expected_count: input.length)
    end
  end

  private

  def normalized_api_base(api_base)
    api_base = api_base.chomp('/')
    api_base.end_with?('/v1') ? api_base : "#{api_base}/v1"
  end

  def http_client(uri)
    Net::HTTP.new(uri.host, uri.port).tap do |http|
      http.use_ssl = uri.scheme == 'https'
      http.open_timeout = 60
      http.read_timeout = 60
      http.write_timeout = 60
    end
  end

  def embeddings_from(response, expected_count:)
    embeddings = response.fetch('data').sort_by { |item| item.fetch('index') }.map { |item| item.fetch('embedding') }
    raise "LiteLLM returned #{embeddings.length} embeddings for #{expected_count} inputs" unless embeddings.length == expected_count

    embeddings.each do |embedding|
      next if embedding.is_a?(Array) && embedding.length == DIMENSIONS && embedding.all?(Numeric)

      raise "LiteLLM returned an embedding that is not #{DIMENSIONS} numeric dimensions"
    end

    embeddings
  end

  def instrument_request(model, request_input, instruction_present, &)
    ActiveSupport::Notifications.instrument(
      INSTRUMENTATION_EVENT,
      model:,
      operation: 'embeddings',
      input_count: request_input.length,
      input_characters: request_input.sum(&:length),
      instruction_present:,
      dimensions: DIMENSIONS,
      &
    )
  end

  def add_response_metadata(payload, response)
    payload[:response_id] = response['id'] if response['id']
    usage = response['usage']
    return unless usage

    payload[:prompt_tokens] = usage['prompt_tokens'] if usage['prompt_tokens']
    payload[:total_tokens] = usage['total_tokens'] if usage['total_tokens']
  end
end
