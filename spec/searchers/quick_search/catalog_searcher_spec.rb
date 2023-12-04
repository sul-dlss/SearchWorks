# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuickSearch::CatalogSearcher do
  subject(:searcher) { described_class.new(HTTP, query, 10) }

  let(:query) { 'my query' }
  let(:response) { JSON.dump({ response: { docs: [] } }) }

  before do
    stub_request(:get, /.*/).to_return(body: response)
  end

  it { expect(searcher.search).to be_an(CatalogSearchService::Response) }
  it do
    searcher.search # loads response
    expect(searcher.results).to be_an(Array)
  end
end
