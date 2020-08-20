# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryWebsiteApiSearchService do
  subject(:service) { described_class.new }

  let(:response) do
    JSON.dump({
      results: [
        {
          title: 'Chinese art: Traditional',
          url: 'https://library.stanford.edu/guides/chinese-art-traditional',
          description: 'This guide...'
        }
      ],
      facets: {
        name: 'format_facet',
        items: [
          {
            value: 'blog',
            label: 'Blog',
            hits: 32,
            term: ['type:blog']
          }
        ]
      }
    })
  end
  let(:query) { LibraryWebsiteApiSearchService::Request.new('chinese art') }

  before do
    allow(Faraday).to receive(:get).and_return(instance_double(Faraday::Response,
                                                               success?: true,
                                                               body: response))
  end

  it { expect(service).to be_an AbstractSearchService }
  it { expect(service.search(query)).to be_an LibraryWebsiteApiSearchService::Response }

  describe '#facets' do
    it 'constructs an API query url' do
      facets = service.search(query).facets
      expect(facets.first).to eq({
        'name' => 'format_facet',
        'items' => [{ 'hits' => 32, 'label' => 'Blog', 'value' => 'type:blog' }]
      })
    end
  end

  describe '#records' do
    it 'sets the title in the document' do
      results = service.search(query).results
      expect(results.length).to eq 1
      expect(results.first.title).to eq 'Chinese art: Traditional'
    end
  end
end
