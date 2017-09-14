require 'rails_helper'

RSpec.describe LibraryWebsiteSearchService do
  subject(:service) { described_class.new }
  let(:query) { LibraryWebsiteSearchService::Request.new('my query') }
  let(:response) { service.search(query) }
  before do
    allow(Faraday).to receive(:get).and_return(instance_double(Faraday::Response,
                                                               success?: true,
                                                               body: body))
  end

  context 'example 1' do
    let(:body) { File.read(Rails.root.join('spec', 'fixtures', 'library.stanford.edu', '1.html')) }

    it '#results' do
      results = response.results
      expect(results.length).to eq 3
      expect(results.first.to_h).to include(title: 'Darren Hardy PhD',
                                            link: '/people/drh',
                                            breadcrumbs: ' » ',
                                            description: /Darren Hardy develops/)
    end
    it '#facets' do
      facets = response.facets
      expect(facets.length).to eq 1
      expect(facets.first).to include('name' => 'document_type_facet')
      expect(facets.first['items'].length).to eq 2
      expect(facets.first['items'][0]).to include('value' => 'Blog', 'label' => 'Blog', 'hits' => 4)
      expect(facets.first['items'][1]).to include('value' => 'Person', 'label' => 'Person', 'hits' => 2)
    end
    it '#total' do
      expect(response.total).to be_nil
    end
  end
end
