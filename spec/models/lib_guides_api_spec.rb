# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LibGuidesApi do
  subject(:api) { described_class.new('Search Term') }

  context 'when the API responds successfully' do
    it 'returns data from the API response as json' do
      allow(Faraday).to receive(:get).and_return(
        double(success?: true, body: [{ name: 'Guide Name', url: 'https://example.com/1' }].to_json)
      )
      expect(api.as_json).to eq([{ 'name' => 'Guide Name', 'url' => 'https://example.com/1' }])
    end

    it "caps the number of results returned to #{Settings.LIB_GUIDES.NUM_RESULTS}" do
      json = Array.new(Settings.LIB_GUIDES.NUM_RESULTS * 3) do |i|
        { nam: "Guide Name #{i}", url: "https://example.com/#{i}" }
      end.to_json
      allow(Faraday).to receive(:get).and_return(double(success?: true, body: json))

      expect(api.as_json.length).to be Settings.LIB_GUIDES.NUM_RESULTS
    end
  end

  context 'when the API fails to respond successfully' do
    before do
      allow(Faraday).to receive(:get).and_return(
        double(success?: false, body: '<html>')
      )
    end

    it 'handles the response and returns an empty array' do
      expect(api.as_json).to eq([])
    end
  end

  context 'when the API claims to return successfully but has malformed JSON' do
    before do
      allow(Faraday).to receive(:get).and_return(
        double(success?: true, body: '<html>')
      )
    end

    it 'handles the response and returns an empty array' do
      expect(api.as_json).to eq([])
    end
  end
end
