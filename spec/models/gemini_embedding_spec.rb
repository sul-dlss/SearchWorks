# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GeminiEmbedding do
  subject(:client) { described_class.new }

  let(:http) { instance_double(Net::HTTP) }
  let(:vector) { Array.new(described_class::DIMENSIONS, 0.25) }
  let(:response) do
    instance_double(
      Net::HTTPOK,
      code: '200',
      body: {
        id: 'embedding-request-123',
        data: [{ index: 0, embedding: vector }],
        usage: { prompt_tokens: 7, total_tokens: 7 }
      }.to_json
    )
  end

  before do
    stub_const('ENV', ENV.to_h.merge(
                        'LITELLM_API_BASE' => 'https://litellm.example',
                        'LITELLM_API_KEY' => 'proxy-key',
                        'LITELLM_EMBEDDING_MODEL' => 'gemini-embedding-2'
                      ))
    allow(Net::HTTP).to receive(:new).with('litellm.example', 443).and_return(http)
    allow(http).to receive(:use_ssl=).with(true)
    allow(http).to receive(:open_timeout=).with(60)
    allow(http).to receive(:read_timeout=).with(60)
    allow(http).to receive(:write_timeout=).with(60)
    allow(http).to receive(:request).and_return(response)
    allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
    allow(response).to receive(:[]).and_return(nil)
  end

  it 'sends an authenticated, instructed 768-dimensional embedding request' do
    expect(http).to receive(:request) do |request|
      expect(request).to be_a(Net::HTTP::Post)
      expect(request.uri.to_s).to eq('https://litellm.example/v1/embeddings')
      expect(request['Authorization']).to eq('Bearer proxy-key')
      expect(JSON.parse(request.body)).to eq(
        'model' => 'gemini-embedding-2',
        'input' => ['task: search result | query: frogs'],
        'dimensions' => 768
      )
      response
    end

    expect(client.embedding(input: ['frogs'], instruction: described_class::DEFAULT_QUERY_INSTRUCTION)).to eq([vector])
  end

  it 'instruments the request without exposing the query or API key' do
    events = []
    subscriber = ActiveSupport::Notifications.subscribe(described_class::INSTRUMENTATION_EVENT) { |event| events << event }

    client.embedding(input: ['sensitive query'], instruction: described_class::DEFAULT_QUERY_INSTRUCTION)

    expect(events.one?).to be true
    expect(events.first.payload).to include(
      model: 'gemini-embedding-2',
      operation: 'embeddings',
      input_count: 1,
      input_characters: 44,
      instruction_present: true,
      dimensions: 768,
      http_status: 200,
      response_id: 'embedding-request-123',
      prompt_tokens: 7,
      total_tokens: 7
    )
    expect(events.first.payload.to_json).not_to include('sensitive', 'proxy-key')
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  it 'raises an error for a response with the wrong vector dimensions' do
    allow(response).to receive(:body).and_return({ data: [{ index: 0, embedding: [0.1] }] }.to_json)

    expect { client.embedding(input: ['text']) }
      .to raise_error(RuntimeError, 'LiteLLM returned an embedding that is not 768 numeric dimensions')
  end

  it 'includes response details when LiteLLM returns an error' do
    error_response = instance_double(Net::HTTPUnauthorized, code: '401', body: '{"error":"invalid key"}')
    allow(error_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)
    allow(error_response).to receive(:[]).and_return(nil)
    allow(http).to receive(:request).and_return(error_response)

    expect { client.embedding(input: ['text']) }
      .to raise_error(RuntimeError, 'LiteLLM embedding request failed (401): {"error":"invalid key"}')
  end
end
