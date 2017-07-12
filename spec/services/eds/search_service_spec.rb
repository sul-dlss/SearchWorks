require 'spec_helper'

RSpec.describe Eds::SearchService do
  let(:blacklight_config) {
    instance_double(
      Blacklight::Configuration,
      repository_class: Eds::Repository,
      search_builder_class: Blacklight::SearchBuilder
    )
  }
  subject(:instance) { described_class.new(blacklight_config) }
  subject(:user_params) { {} }

  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
    stub_article_service(type: :single, docs: [StubArticleService::SAMPLE_RESULTS.first])
  end

  it '#search_results' do
    results = instance.search_results(user_params)
    expect(results.length).to eq 2
    expect(results[0]).to be_an(Blacklight::Solr::Response)
    expect(results[1]).to eq StubArticleService::SAMPLE_RESULTS
  end

  it '#fetch' do
    results = instance.fetch(StubArticleService::SAMPLE_RESULTS.first.id)
    expect(results.length).to eq 2
    expect(results[0]).to be_an(Blacklight::Solr::Response)
    expect(results[1].id).to eq StubArticleService::SAMPLE_RESULTS.first.id
  end
end
