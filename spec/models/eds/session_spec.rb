# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Eds::Session do
  subject(:session) { described_class.new(host: 'https://eds.example.com') }

  let(:info_url) { 'https://eds.example.com/edsapi/rest/Info' }

  before do
    stub_request(:post, 'https://eds.example.com/authservice/rest/uidauth')
      .to_return(status: 200, body: { AuthToken: 'auth' }.to_json, headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, %r{https://eds.example.com/edsapi/rest/CreateSession})
      .to_return(status: 200, body: { SessionToken: 'session' }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  describe 'error handling' do
    it 'retries once with a new auth token when the auth token has expired' do
      stub_request(:get, info_url)
        .to_return({ status: 400, body: { ErrorNumber: '104' }.to_json, headers: { 'Content-Type' => 'application/json' } },
                   { status: 200, body: { AvailableSearchCriteria: {} }.to_json, headers: { 'Content-Type' => 'application/json' } })

      expect(session.info).to eq('AvailableSearchCriteria' => {})
      expect(a_request(:get, info_url)).to have_been_made.twice
    end

    it 'gives up after one auth token retry' do
      stub_request(:get, info_url)
        .to_return(status: 400, body: { ErrorNumber: '107' }.to_json, headers: { 'Content-Type' => 'application/json' })

      expect { session.info }.to raise_error(Faraday::BadRequestError)
      expect(a_request(:get, info_url)).to have_been_made.twice
    end

    it 're-raises timeouts as Faraday errors' do
      stub_request(:get, info_url).to_timeout

      expect { session.info }.to raise_error(Faraday::Error)
    end

    it 're-raises errors with a non-JSON body as Faraday errors' do
      stub_request(:get, info_url).to_return(status: 502, body: 'Bad Gateway')

      expect { session.info }.to raise_error(Faraday::ServerError)
    end

    it 're-raises search timeouts as Faraday errors' do
      stub_request(:post, 'https://eds.example.com/edsapi/rest/Search').to_timeout

      expect { session.search({}) }.to raise_error(Faraday::Error)
    end
  end
end
