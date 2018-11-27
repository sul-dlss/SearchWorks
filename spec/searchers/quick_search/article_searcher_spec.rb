# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuickSearch::ArticleSearcher do
  subject(:searcher) { described_class.new(instance_double(HTTPClient), query, 10) }
  let(:query) { 'my query' }
  let(:response) { JSON.dump(response: { docs: [] }) }

  before do
    allow(Faraday).to receive(:get).and_return(instance_double(Faraday::Response,
                                                               success?: true,
                                                               body: response))
  end
  it { expect(searcher).to be_an(QuickSearch::Searcher) }
  it { expect(searcher.search).to be_an(ArticleSearchService::Response) }
  it do
    searcher.search # loads response
    expect(searcher.results).to be_an(Array)
  end
end
