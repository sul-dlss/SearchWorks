# frozen_string_literal: true

require "rails_helper"

RSpec.describe Chat::LiteLlmClient do
  let(:http) { instance_double(Net::HTTP) }
  let(:response) { Net::HTTPOK.new("1.1", "200", "OK") }

  before do
    allow(Net::HTTP).to receive(:new).with("litellm.example", 443).and_return(http)
    allow(http).to receive(:use_ssl=).with(true)
    allow(http).to receive(:open_timeout=).with(10)
    allow(http).to receive(:read_timeout=).with(120)
  end

  it "posts an authenticated JSON request to the normalized API endpoint" do
    allow(http).to receive(:request) do |request, &block|
      expect(request.uri.to_s).to eq("https://litellm.example/v1/chat/completions")
      expect(request["Authorization"]).to eq("Bearer proxy-key")
      expect(request["Content-Type"]).to eq("application/json")
      expect(request["Accept"]).to eq("text/event-stream")
      expect(request.body).to eq('{"messages":[]}')
      block.call(response)
    end

    client = described_class.new(api_base: "https://litellm.example/v1/", api_key: "proxy-key")

    expect do |block|
      client.post(
        "chat/completions",
        body: '{"messages":[]}',
        headers: { "Accept" => "text/event-stream" },
        &block
      )
    end.to yield_with_args(response)
  end

  it "requires a configured API base" do
    expect { described_class.new(api_base: nil, api_key: "proxy-key") }
      .to raise_error(RuntimeError, "LITELLM_API_BASE environment variable is not set")
  end

  it "requires a configured API key" do
    expect { described_class.new(api_base: "https://litellm.example", api_key: nil) }
      .to raise_error(RuntimeError, "LITELLM_API_KEY environment variable is not set")
  end
end
