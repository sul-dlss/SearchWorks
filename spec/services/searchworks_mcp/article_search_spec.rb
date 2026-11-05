# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchworksMcp::ArticleSearch do
  describe '.search' do
    let(:response) { instance_double(Eds::Response, documents: [], total: 0) }
    let(:search_service) { instance_double(Eds::SearchService, search_results: response) }
    let(:session) { instance_double(Eds::Session, session_token: 'token') }

    before do
      allow(Settings).to receive(:EDS_ENABLED).and_return(true)
      allow(Eds::Session).to receive(:new).and_return(session)
      allow(Eds::SearchService).to receive(:new).and_return(search_service)
    end

    it 'passes the requested number of rows to EDS as per_page' do
      described_class.search(query: 'climate', rows: 5)

      expect(Eds::SearchService).to have_received(:new)
        .with(anything, hash_including(per_page: 5, q: 'climate', search_field: 'search'), anything)
    end

    it 'caps the page size at 20' do
      described_class.search(query: 'climate', rows: 100)

      expect(Eds::SearchService).to have_received(:new).with(anything, hash_including(per_page: 20), anything)
    end

    it 'does not apply any limiters by default' do
      described_class.search(query: 'climate')

      expect(Eds::SearchService).to have_received(:new).with(anything, hash_excluding(:f), anything)
    end

    it 'applies the full text and peer-reviewed limiters when requested' do
      described_class.search(query: 'climate', full_text_only: true, peer_reviewed_only: true)

      expect(Eds::SearchService).to have_received(:new).with(
        anything,
        hash_including(f: { 'eds_search_limiters_facet' => ['Direct access to full text', 'Scholarly & peer-reviewed only'] }),
        anything
      )
    end

    it 'applies only the requested limiter' do
      described_class.search(query: 'climate', peer_reviewed_only: true)

      expect(Eds::SearchService).to have_received(:new).with(
        anything,
        hash_including(f: { 'eds_search_limiters_facet' => ['Scholarly & peer-reviewed only'] }),
        anything
      )
    end

    it 'applies a publication year range' do
      described_class.search(query: 'climate', start_year: 2010, end_year: 2020)

      expect(Eds::SearchService).to have_received(:new)
        .with(anything, hash_including(range: { pub_year_tisim: { begin: '2010', end: '2020' } }), anything)
    end

    it 'fills in the open end of a one-sided year range and swaps reversed years' do
      described_class.search(query: 'climate', start_year: 2020, end_year: 2010)
      described_class.search(query: 'climate', start_year: 2015)

      expect(Eds::SearchService).to have_received(:new)
        .with(anything, hash_including(range: { pub_year_tisim: { begin: '2010', end: '2020' } }), anything)
      expect(Eds::SearchService).to have_received(:new)
        .with(anything, hash_including(range: { pub_year_tisim: { begin: '2015', end: (Time.zone.now.year + 1).to_s } }), anything)
    end

    it 'filters by source type' do
      described_class.search(query: 'climate', source_type: 'Academic Journals')

      expect(Eds::SearchService).to have_received(:new)
        .with(anything, hash_including(f: { 'eds_publication_type_facet' => ['Academic Journals'] }), anything)
    end

    context 'with source type facets in the response' do
      let(:source_types) do
        Eds::Response::FacetField.new('SourceType', [Eds::Response::FacetValue.new(value: 'Academic Journals', hits: 120),
                                                     Eds::Response::FacetValue.new(value: 'News', hits: 30)])
      end
      let(:response) { instance_double(Eds::Response, documents: [], total: 150, aggregations: { 'SourceType' => source_types }) }

      it 'returns the source type values clients can filter on' do
        result = described_class.search(query: 'climate')

        expect(result.dig(:structured_content, :facets)).to eq(
          'source_type' => { label: 'Source type', values: [{ value: 'Academic Journals', count: 120 }, { value: 'News', count: 30 }] }
        )
        expect(result[:text]).to include('- Source type: Academic Journals (120), News (30)')
        expect(result[:structured_content]).not_to have_key(:without_filters)
      end
    end

    context 'when EDS ignores an unrecognized source type' do
      let(:source_types) do
        Eds::Response::FacetField.new('SourceType', [Eds::Response::FacetValue.new(value: 'Academic Journals', hits: 120)])
      end
      let(:response) { instance_double(Eds::Response, documents: [], total: 150, aggregations: { 'SourceType' => source_types }) }

      it 'warns that the results are not filtered by source type' do
        result = described_class.search(query: 'climate', source_type: 'academic journal')

        expect(result.dig(:structured_content, :warnings)).to contain_exactly(a_string_including('"academic journal" does not match'))
        expect(result[:text]).to start_with('Warning: Source type "academic journal" does not match')
      end

      it 'does not warn when the source type matches' do
        result = described_class.search(query: 'climate', source_type: 'Academic Journals')

        expect(result[:structured_content]).not_to have_key(:warnings)
      end
    end

    context 'when filters remove every result' do
      let(:unfiltered_response) do
        instance_double(Eds::Response, documents: [], total: 42, aggregations: {
                          'SourceType' => Eds::Response::FacetField.new('SourceType', [Eds::Response::FacetValue.new(value: 'News', hits: 42)])
                        })
      end
      let(:unfiltered_service) { instance_double(Eds::SearchService, search_results: unfiltered_response) }

      before do
        allow(Eds::SearchService).to receive(:new).with(anything, hash_excluding(:f, :range), anything).and_return(unfiltered_service)
      end

      it 'reports results and facets for the query without filters' do
        result = described_class.search(query: 'climate', source_type: 'Academic Journal', start_year: 2020, peer_reviewed_only: true)

        expect(result.dig(:structured_content, :filters)).to eq(start_year: 2020, source_type: 'Academic Journal', peer_reviewed_only: true)
        expect(result.dig(:structured_content, :without_filters)).to eq(
          total: 42, facets: { 'source_type' => { label: 'Source type', values: [{ value: 'News', count: 42 }] } }
        )
        expect(result[:text]).to include('Without filters, this query has 42 articles', '- Source type: News (42)')
      end
    end

    it 'does not run a fallback search when no filters were applied' do
      result = described_class.search(query: 'climate')

      expect(Eds::SearchService).to have_received(:new).once
      expect(result[:structured_content]).not_to have_key(:without_filters)
    end
  end
end
