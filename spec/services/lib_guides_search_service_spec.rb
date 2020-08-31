# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibGuidesSearchService do
  subject(:service) { described_class.new }

  let(:response) do
    JSON.dump([
      {
        id: "1050350",
        name: "World languages education",
        description: "This guide is for those interested in the teaching of world languages, both research and practice.",
        redirect_url: "",
        status: "1",
        published: "2020-06-15 18:20:56",
        created: "2020-06-15 16:20:25",
        updated: "2020-06-15 18:20:56",
        slug_id: "2081241",
        slug: "world_languages_ed",
        friendly_url: "world_languages_ed",
        nav_type: "0",
        count_hit: "12",
        url: "https://guides.library.stanford.edu/c.php?g=1050350",
        status_label: "Published",
        type_label: "Topic Guide"
      }
    ])
  end
  let(:query) { LibGuidesSearchService::Request.new('my query') }

  before do
    stub_request(:get, /.*/).to_return(body: response)
  end

  it { expect(service).to be_an AbstractSearchService }
  it { expect(service.search(query)).to be_an LibGuidesSearchService::Response }

  describe '#query_url' do
    it 'constructs an API query url' do
      expect(service.query_url).to eq 'https://example.com/1.1/guides?key=abc1234&site_id=123456&sort_by=relevance&status=1&search_terms=%{q}'
    end
  end

  describe '#records' do
    it 'is set by the fulltext_link_html field in the document' do
      results = service.search(query).results
      expect(results.length).to eq 1
      expect(results.first.title).to eq 'World languages education'
    end
  end
end
