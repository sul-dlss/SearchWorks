# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuickSearch::ExhibitsSearcher do
  subject(:searcher) { described_class.new(HTTP, query) }

  let(:query) { 'my query' }
  let(:response) { JSON.dump([]) }

  before do
    stub_request(:get, /.*/).to_return(body: response)
  end

  it { expect(searcher.search).to be_an(ExhibitsSearchService::Response) }

  it do
    searcher.search # loads response
    expect(searcher.results).to be_an(Array)
  end
end
