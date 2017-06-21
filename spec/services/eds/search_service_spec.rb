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

  it '#search_results' do
    expect(instance.respond_to?(:search_results)).to be_truthy
    expect(instance.repository).to receive(:search)
    expect(instance.search_results).to be_truthy
  end

  it '#fetch' do
    expect(instance.respond_to?(:fetch)).to be_truthy
    expect(instance.repository).to receive(:find).and_return(instance_double(Blacklight::Solr::Response, documents: []))
    expect(instance.fetch).to be_truthy
  end
end
