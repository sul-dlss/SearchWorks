# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryWebsiteSearchService do
  context 'request/response' do
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
        expect(facets.first['items'][0]).to include('value' => 'type:blog', 'label' => 'Blog', 'hits' => 4)
        expect(facets.first['items'][1]).to include('value' => 'type:person', 'label' => 'Person', 'hits' => 2)
      end
      it '#total' do
        expect(response.total).to be_nil
      end
    end

    context 'example 2' do
      let(:body) { File.read(Rails.root.join('spec', 'fixtures', 'library.stanford.edu', '2.html')) }

      it '#results' do
        results = response.results
        expect(results.length).to eq 3
        expect(results.first.to_h).to include(title: 'Books',
                                              link: '/department/metadata-department/services/new-record-or-record-change-requests/books',
                                              breadcrumbs: ' » ',
                                              description: /Document for new record and record change/)
      end
      it '#facets' do
        facets = response.facets
        expect(facets.length).to eq 1
        expect(facets.first).to include('name' => 'document_type_facet')
        expect(facets.first['items'].length).to eq 16
        expect(facets.first['items'][0]).to include('value' => 'type:site_microsite', 'label' => 'Group page', 'hits' => 946)
        expect(facets.first['items'][1]).to include('value' => 'type:library_page', 'label' => 'Library microsite', 'hits' => 566)
      end
      it '#total' do
        expect(response.total).to be_nil
      end
    end
  end

  context 'facets' do
    let(:facet_hash) { { 'label' => 'Facet Label', 'value' => 'type:facet value', 'hits' => 20 } }

    let(:facet_item) do
      LibraryWebsiteSearchService::HighlightedFacetItem.new(facet_hash, 'facet_name', 'http://example.com/?q=%{q}')
    end

    it 'has attributes matched to hash accessors' do
      expect(facet_item.label).to eq 'Facet Label'
      expect(facet_item.value).to eq 'type:facet value'
      expect(facet_item.hits).to be 20
    end

    describe 'query_url' do
      it 'interpolates the q attribute' do
        expect(facet_item.query_url('abc')).to include 'example.com/?q=abc'
      end

      it 'appends the transformed facet value' do
        expect(facet_item.query_url('abc')).to include '&f[0]=type%3Afacet+value'
      end
    end
  end
end
