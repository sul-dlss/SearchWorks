# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuickSearch::LibGuidesSearcher do
  subject(:searcher) { described_class.new(HTTP, query, 10) }

  let(:query) { 'my query' }
  let(:response) { JSON.dump([]) }

  before do
    stub_request(:get, /.*/).to_return(body: response)
  end

  it { expect(searcher.search).to be_an(LibGuidesSearchService::Response) }
  it { expect(searcher).to be_toggleable }
  it { expect(searcher.toggle_threshold).to be 3 }
  it do
    searcher.search # loads response
    expect(searcher.results).to be_an(Array)
  end
end
