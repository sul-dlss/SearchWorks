# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OclcDiscoveryClient do
  subject(:client) { described_class.new(base_url:, client_key:, client_secret:, token_url:, authorize_url:) }

  let(:base_url) { 'https://oclc.example.edu' }
  let(:client_key) { 'client-key' }
  let(:client_secret) { 'client-secret' }
  let(:token_url) { 'https://oclc.example.edu/token?scope=DISCOVERY_Citations&grant_type=client_credentials' }
  let(:authorize_url) { 'https://oclc.example.edu/authorize' }

  let(:oauth_client) { instance_double(OAuth2::Client) }

  before do
    allow(OAuth2::Client).to receive(:new).with(client_key, client_secret, site: base_url, token_url:, authorize_url:).and_return(oauth_client)
    allow(oauth_client).to receive_message_chain(:client_credentials, :get_token, :token).and_return('token') # rubocop:disable RSpec/MessageChain
  end

  describe '#ping' do
    subject(:ping) { client.ping }

    it 'returns true if the session token is present' do
      expect(ping).to be true
    end
  end

  describe '#citations' do
    subject(:citations) { client.citations(oclc_numbers: '905869', citation_styles: 'modern-language-association') }

    before do
      stub_request(:get, "https://oclc.example.edu/reference/citations?oclcNumbers=905869&style=modern-language-association")
        .with(headers: { 'Accept' => 'application/json',
                         'Accept-Language' => 'en',
                         'Authorization' => 'Bearer token',
                         'Connection' => 'close',
                         'Host' => 'oclc.example.edu',
                         'User-Agent' => 'Stanford Libraries SearchWorks' })
        .to_return(status: 200, body: "{\"entries\":\"citation\"}", headers: {})
    end

    it 'returns citations' do
      expect(citations).to eq([{ 'entries' => 'citation' }])
    end
  end
end
