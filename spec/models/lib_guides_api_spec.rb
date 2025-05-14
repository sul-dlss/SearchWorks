# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibGuidesApi do
  let(:term) { 'Search Term' }

  subject(:api) { described_class.new(term) }

  describe 'user search term encoding' do
    let(:term) { 'Kōzanji' }

    it 'encodes the users query' do
      url = api.send(:url)

      expect(url).not_to include(term)
      expect(url).to include('Ko%CC%84zanji')
    end
  end

  context 'when the API responds successfully' do
    before do
      allow(Faraday).to receive(:get).and_return(
        double(success?: true, body: [{ name: 'Guide Name', url: 'https://example.com/1' }].to_json)
      )
    end

    it 'returns a count' do
      expect(api.as_json).to eq({ meta: { pages: { total_count: 1 } } })
    end
  end

  context 'when the API fails to respond successfully' do
    before do
      allow(Faraday).to receive(:get).and_return(
        double(success?: false, body: '<html>')
      )
    end

    it 'returns a zero count' do
      expect(api.as_json).to eq({ meta: { pages: { total_count: 0 } } })
    end
  end

  context 'when the API claims to return successfully but has malformed JSON' do
    before do
      allow(Faraday).to receive(:get).and_return(
        double(success?: true, body: '<html>')
      )
    end

    it 'returns a zero count' do
      expect(api.as_json).to eq({ meta: { pages: { total_count: 0 } } })
    end
  end
end
