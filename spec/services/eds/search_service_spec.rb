# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Eds::SearchService do
  let(:document_model) { double(unique_key: :id) }
  let(:blacklight_config) {
    instance_double(
      Blacklight::Configuration,
      repository_class: Eds::Repository,
      search_builder_class: Blacklight::SearchBuilder,
      document_model:
    )
  }

  subject(:instance) { described_class.new(blacklight_config, user_params) }

  subject(:user_params) { {} }

  context 'with a single document' do
    before do
      stub_article_service(type: :single, docs: [StubArticleService::SAMPLE_RESULTS.first])
    end

    it '#fetch_one' do
      results = instance.fetch(StubArticleService::SAMPLE_RESULTS.first.id)
      expect(results.length).to eq 2
      expect(results[0]).to be_an(Blacklight::Solr::Response)
      expect(results[1].id).to eq StubArticleService::SAMPLE_RESULTS.first.id
    end

    describe '#fetch' do
      it 'returns a single result' do
        results = instance.fetch('a')
        expect(results[1].id).to eq StubArticleService::SAMPLE_RESULTS.first.id
        expect(results[1]).to be_an SolrDocument
      end
    end
  end

  context 'with multiple documents' do
    before do
      stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
    end

    it '#search_results' do
      results = instance.search_results
      expect(results.length).to eq 2
      expect(results[0]).to be_an(Blacklight::Solr::Response)
      expect(results[1]).to eq StubArticleService::SAMPLE_RESULTS
    end

    it '#fetch_many' do
      results = instance.fetch_many(StubArticleService::SAMPLE_RESULTS.map(&:id), {})
      expect(results.length).to eq 2
      expect(results[0]).to be_an(Blacklight::Solr::Response)
      expect(results[1].count).to eq StubArticleService::SAMPLE_RESULTS.count
    end

    describe '#fetch' do
      it 'returns an array of results' do
        results = instance.fetch(%w[a b])
        expect(results[1].count).to eq StubArticleService::SAMPLE_RESULTS.count
        expect(results[1]).to be_an Array
      end
    end
  end

  context '#PagingWindow and #previous_and_next_document_params' do
    let(:hit) { 0 } # index is 0-based
    let(:max) { 999_999_999 }
    let(:window) { Eds::SearchService::PagingWindow.new(hit, max) }

    context 'first hit' do
      it 'first page without a previous hit' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 1 # start_page is 1-based
        expect(window.per_page).to eq 10
        expect(window.prev_hit).to be_nil
        expect(window.next_hit).to eq 1
      end
    end

    context 'second hit' do
      let(:hit) { 1 }
      let(:previous_and_next_document_params) { @eds_params, @prev_hit, @next_hit = [{ page_number: 1, results_per_page: 10 }, 0, 2] }

      it 'first page with both prev/next hits' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 1
        expect(window.per_page).to eq 10
        expect(window.prev_hit).to eq 0
        expect(window.next_hit).to eq 2
      end
    end

    context 'tenth hit (boundary condition)' do
      let(:hit) { 9 }

      it 'first page with both prev/next hits' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 1
        expect(window.per_page).to eq 11
        expect(window.prev_hit).to eq 8
        expect(window.next_hit).to eq 10
      end
    end

    context 'eleventh hit (boundary condition)' do
      let(:hit) { 10 }

      it 'first page with both prev/next hits' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 1
        expect(window.per_page).to eq 12
        expect(window.prev_hit).to eq 9
        expect(window.next_hit).to eq 11
      end
    end

    context 'last hit (boundary condition)' do
      let(:hit) { 9 }
      let(:max) { 10 }

      it 'last page without a next hit (preserves per_page size)' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 1
        expect(window.per_page).to eq 10
        expect(window.prev_hit).to eq 8
        expect(window.next_hit).to be_nil
      end
    end

    context 'middle of page hit (probed)' do
      let(:hit) { 32 }

      it 'is in middle' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 4
        expect(window.per_page).to eq 10
        expect(window.prev_hit).to eq 1
        expect(window.next_hit).to eq 3
      end
    end

    context 'last hit (probed)' do
      let(:hit) { 39 }
      let(:max) { 40 }

      it 'last page without a next hit' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 4
        expect(window.per_page).to eq 10
        expect(window.prev_hit).to eq 8
        expect(window.next_hit).to be_nil
      end
    end

    context 'only hit' do
      let(:hit) { 0 }
      let(:max) { 1 }

      it 'no prev or next' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 1
        expect(window.per_page).to eq 10
        expect(window.prev_hit).to be_nil
        expect(window.next_hit).to be_nil
      end
    end

    context 'last hit on short list' do
      let(:hit) { 1 }
      let(:max) { 2 }

      it 'no next' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 1
        expect(window.per_page).to eq 10
        expect(window.prev_hit).to eq 0
        expect(window.next_hit).to be_nil
      end
    end

    context 'invalid hit' do
      let(:hit) { 999 }
      let(:max) { 40 }

      it 'raises error' do
        expect { window }.to raise_error(ArgumentError)
      end
    end

    context 'negative hit' do
      let(:hit) { -1 }

      it 'raises error' do
        expect { window }.to raise_error(ArgumentError)
      end
    end
  end

  context '#previous_and_next_documents_for_search' do
    let(:hit) { 1 }

    before do
      stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
    end

    it 'finds the prev/next docs' do
      _response, @docs = instance.previous_and_next_documents_for_search(hit, { q: 'my query' })
      expect(@docs.first).to be_truthy
      expect(@docs.first['id']).to eq 'abc123'
      expect(@docs.last).to be_truthy
      expect(@docs.last['id']).to eq 'wq/oeif.zzz'
    end

    context 'last hit' do
      let(:hit) { StubArticleService::SAMPLE_RESULTS.length - 1 }

      it 'grabs the penultimate hit for the previous doc but no next doc' do
        _response, @docs = instance.previous_and_next_documents_for_search(hit, { q: 'my query' })
        expect(@docs.first).to be_truthy
        expect(@docs.first['id']).to eq 'wq/oeif.zzz'
        expect(@docs.last).to be_nil
      end
    end

    context 'negative hit' do
      let(:hit) { -1 }

      it 'raises error on params' do
        expect { instance.previous_and_next_documents_for_search(hit, {}) }.to raise_error(ArgumentError)
      end
    end
  end
end
