# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EarthworksSearchService do
  subject(:service) { described_class.new }

  let(:response) do
    Rails.root.join('spec/fixtures/earthworks.json').read
  end

  let(:query) { 'my query' }

  before do
    stub_request(:get, /.*/).to_return(body: response)
  end

  it { expect(service).to be_an described_class }
  it { expect(service.search(query)).to be_an EarthworksSearchService::Response }

  describe '#results' do
    it 'returns the relevant metadata from the API' do
      results = service.search(query).results
      expect(results.length).to eq 3
      expect(results.first).to have_attributes(
        title: 'Groundwater',
        description: nil,
        link: 'https://earthworks.stanford.edu/catalog/ark28722-s73k54',
        format: 'Polygon',
        icon: 'earthworks/polygon.svg',
        date: 'Temporal Coverage: 2003',
        coverage: 'Place: Marin County (Calif.)',
        author: nil
      )
    end
  end
end
