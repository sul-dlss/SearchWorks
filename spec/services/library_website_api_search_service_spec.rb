# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryWebsiteApiSearchService do
  subject(:service) { described_class.new }

  let(:response) do
    JSON.dump(
      {
        "jsonapi": {
          "version": "1.0",
          "meta": {
            "links": {
              "self": {
                "href": "http://jsonapi.org/format/1.0/"
              }
            }
          }
        },
        "data": [
          {
            "type": "node--stanford_page",
            "id": "0ad8a8c0-9c66-4fdc-96e5-ab0b6dabd8a0",
            "links": {
              "self": {
                "href": "https://library.sites-pro.stanford.edu/jsonapi/node/stanford_page/0ad8a8c0-9c66-4fdc-96e5-ab0b6dabd8a0?resourceVersion=id%3A17206"
              }
            },
            "attributes": {
              "title": "Work with data",
              "path": {
                "alias": "/services/work-data",
                "pid": 2086,
                "langcode": "en"
              },
              "su_page_description": "First result description"
            }
          },
          {
            "type": "node--stanford_page",
            "id": "e1117434-f6d7-448a-9d4a-80f7e4bc992a",
            "links": {
              "self": {
                "href": "https://library.sites-pro.stanford.edu/jsonapi/node/stanford_page/e1117434-f6d7-448a-9d4a-80f7e4bc992a?resourceVersion=id%3A18441"
              }
            },
            "attributes": {
              "title": "Promote your research",
              "path": {
                "alias": "/services/promote-your-research",
                "pid": 2351,
                "langcode": "en"
              },
              "su_page_description": "this is a page that describes how Stanford Libraries can help students and scholars to promote their research"
            }
          }
        ],
        "meta": {
          "count": 207
        }
      }
    )
  end
  let(:query) { LibraryWebsiteApiSearchService::Request.new('chinese art') }

  before do
    stub_request(:get, /.*/).to_return(body: response)
  end

  it { expect(service).to be_an AbstractSearchService }
  it { expect(service.search(query)).to be_an LibraryWebsiteApiSearchService::Response }

  describe '#records' do
    it 'sets the title, description, and link in the document' do
      results = service.search(query).results
      expect(results.length).to eq 2
      expect(results.first.title).to eq 'Work with data'
      expect(results.first.description).to eq 'First result description'
      expect(results.first.link).to eq '/services/work-data'
    end
  end

  describe '#facets' do
    it 'returns an empty array' do
      facets = service.search(query).facets
      expect(facets).to eq []
    end
  end

  describe '#total' do
    it 'returns an empty array' do
      count = service.search(query).total
      expect(count).to eq 207
    end
  end
end
