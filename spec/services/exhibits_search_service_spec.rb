# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExhibitsSearchService do
  subject(:service) { described_class.new }

  let(:response) do
    JSON.dump([
      {
        title: 'Exhibit Title',
        slug: 'exhibit-slug',
        subtitle: 'The subtitle of the exhibit',
        thumbnail_url: 'https://example.com/kitten.jpg'
      }
    ])
  end
  let(:query) { ExhibitsSearchService::Request.new('my query') }

  before do
    allow(Faraday).to receive(:get).and_return(instance_double(Faraday::Response,
                                                               success?: true,
                                                               body: response))
  end

  it { expect(service).to be_an AbstractSearchService }
  it { expect(service.search(query)).to be_an ExhibitsSearchService::Response }

  describe '#records' do
    it 'returns the relevant metadata from the API' do
      results = service.search(query).results
      expect(results.length).to eq 1
      expect(results.first.title).to eq 'Exhibit Title'
      expect(results.first.description).to eq 'The subtitle of the exhibit'
      expect(results.first.link).to eq 'https://exhibits.stanford.edu/exhibit-slug'
      expect(results.first.thumbnail).to eq 'https://example.com/kitten.jpg'
    end
  end
end
