# frozen_string_literal: true

require 'rails_helper'
RSpec.describe QuickSearch::LibraryWebsiteApiSearcher do
  subject(:searcher) { described_class.new(HTTP, query, 10) }

  let(:query) { 'my query' }
  let(:body) do
    {
      data: [
        {
          type: 'node--stanford_page',
          id: '0ad8a8c0-9c66-4fdc-96e5-ab0b6dabd8a0',
          links: {
            self: {
              href: 'https://library.sites-pro.stanford.edu/jsonapi/node/stanford_page/0ad8a8c0-9c66-4fdc-96e5-ab0b6dabd8a0?resourceVersion=id%3A17206'
            }
          },
          attributes: {
            title: 'Work with data',
            path: {
              alias: '/services/work-data',
              pid: 2086,
              langcode: 'en'
            },
            su_page_description: 'First result description'
          }
        }
      ]
    }
  end

  before do
    stub_request(:get, /.*/).to_return(body: body.to_json)
  end

  it { expect(searcher.search).to be_an(LibraryWebsiteApiSearchService::Response) }

  it do
    searcher.search # loads response
    expect(searcher.results).to be_an(Array)
  end
end
