# frozen_string_literal: true

require 'rails_helper'

describe AbstractSearchService do
  describe 'Response' do
    let(:response) { AbstractSearchService::Response.new(nil) }

    describe '#highlighted_facet_values' do
      before do
        stub_const('AbstractSearchService::Response::HIGHLIGHTED_FACET_FIELD', 'facet_name')
        stub_const('AbstractSearchService::Response::QUERY_URL', 'http://example.com')

        expect(response).to receive(:facets).at_least(:once).and_return(
          [
            {
              'name' => 'facet_name',
              'items' => [
                { 'label' => 'Facet Label1', 'value' => 'Facet Value1', 'hits' => 20 },
                { 'label' => 'Facet Label2', 'value' => 'Facet Value2', 'hits' => 200 },
                { 'label' => 'Facet Label3', 'value' => 'Facet Value3', 'hits' => 10 },
                { 'label' => 'Facet Label4', 'value' => 'Facet Value4', 'hits' => 1 }
              ]
            }
          ]
        )
      end

      describe 'length based on the count argument' do
        it { expect(response.highlighted_facet_values.length).to eq 3 }
        it { expect(response.highlighted_facet_values(2).length).to eq 2 }
      end

      it 'is an array of HighlightedFacetItem objects' do
        response.highlighted_facet_values.each do |facet|
          expect(facet).to be_a AbstractSearchService::HighlightedFacetItem
        end
      end

      it 'sorts the facets by hit count' do
        hits = response.highlighted_facet_values.map(&:hits)

        expect(hits).to eq([200, 20, 10])
      end
    end
  end

  describe 'HighlightedFacetItem' do
    let(:facet_hash) { { 'label' => 'Facet Label', 'value' => 'Facet Value', 'hits' => 20 } }

    let(:facet_item) do
      AbstractSearchService::HighlightedFacetItem.new(facet_hash, 'facet_name', 'http://example.com/?q=%{q}')
    end

    it 'has attributes matched to hash accessors' do
      expect(facet_item.label).to eq 'Facet Label'
      expect(facet_item.value).to eq 'Facet Value'
      expect(facet_item.hits).to be 20
    end

    describe '#hits' do
      context 'when the hit value is not present' do
        before { facet_hash['hits'] = nil }

        it { expect(facet_item.hits).to be 0 }
      end

      context 'when the hit value is a string' do
        before { facet_hash['hits'] = '200' }

        it { expect(facet_item.hits).to be 200 }
      end
    end

    describe 'query_url' do
      it 'interpolates the q attribute' do
        expect(facet_item.query_url('abc')).to include 'example.com/?q=abc'
      end

      it 'appends the facet value' do
        expect(facet_item.query_url('abc')).to include '&f%5Bfacet_name%5D%5B%5D=Facet+Value'
      end
    end
  end
end
