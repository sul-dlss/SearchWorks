# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuickSearch::LibGuidesSearcher do
  subject(:searcher) { described_class.new(HTTP, query, 10) }

  let(:query) { 'my query' }
  let(:response_hash) { { name: 'name' } }
  let(:response) { JSON.dump(response_list) }

  before do
    stub_request(:get, /.*/).to_return(body: response)
  end

  context 'with 100 results' do
    let(:response_list) { Array.new(100) { response_hash.dup } }

    it { expect(searcher.search).to be_an(LibGuidesSearchService::Response) }

    it do
      searcher.search # loads response
      expect(searcher.results).to be_an(Array)
      expect(searcher.results.length).to be 3
      expect(searcher.total).to be '100+'
    end
  end

  context 'with 55 results' do
    let(:response_list) { Array.new(55) { response_hash.dup } }

    it { expect(searcher.search).to be_an(LibGuidesSearchService::Response) }

    it do
      searcher.search # loads response
      expect(searcher.results).to be_an(Array)
      expect(searcher.results.length).to be 3
      expect(searcher.total).to be 55
    end
  end
end
