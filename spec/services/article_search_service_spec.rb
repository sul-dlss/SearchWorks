# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArticleSearchService do
  subject(:service) { described_class.new }

  let(:response) do
    JSON.dump({
                response: {
                  docs:
                  [
                    { id: 'abc123', eds_composed_title: 'Composed title', fulltext_link_html: '<a href="#">Link</a>' }
                  ]
                }
              })
  end
  let(:query) { ArticleSearchService::Request.new('my query') }

  before do
    stub_request(:get, /.*/).to_return(body: response)
  end

  it { expect(service).to be_an AbstractSearchService }
  it { expect(service.search(query)).to be_an ArticleSearchService::Response }

  describe '#fulltext_link_html' do
    it 'is set by the fulltext_link_html field in the document' do
      results = service.search(query).results
      expect(results.length).to eq 1
      expect(results.first.fulltext_link_html).to eq '<a href="#">Link</a>'
    end
  end
end
