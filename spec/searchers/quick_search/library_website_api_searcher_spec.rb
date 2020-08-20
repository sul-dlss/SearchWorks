# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuickSearch::LibraryWebsiteApiSearcher do
  subject(:searcher) { described_class.new(instance_double(HTTPClient), query, 10) }

  let(:query) { 'my query' }
  let(:body) do
    {
      results: [
        {
          title: 'Chinese art: Traditional',
          url: 'https://library.stanford.edu/guides/chinese-art-traditional',
          description: 'This guide...'
        }
      ]
    }
  end

  before do
    allow(Faraday).to receive(:get).and_return(instance_double(Faraday::Response,
                                                               success?: true,
                                                               body: body.to_json))
  end

  it { expect(searcher).to be_an(QuickSearch::Searcher) }
  it { expect(searcher.search).to be_an(LibraryWebsiteApiSearchService::Response) }
  it do
    searcher.search # loads response
    expect(searcher.results).to be_an(Array)
  end
end
