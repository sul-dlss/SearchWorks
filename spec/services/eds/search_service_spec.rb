require 'spec_helper'

RSpec.describe Eds::SearchService do
  let(:document_model) { double(unique_key: :id) }
  let(:blacklight_config) {
    instance_double(
      Blacklight::Configuration,
      repository_class: Eds::Repository,
      search_builder_class: Blacklight::SearchBuilder,
      document_model: document_model
    )
  }

  subject(:instance) { described_class.new(blacklight_config) }

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
      results = instance.search_results(user_params)
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
end
