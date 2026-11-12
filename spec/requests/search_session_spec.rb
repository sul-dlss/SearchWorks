# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Returning to search results after a mini-bento fetch' do
  it 'returns to the catalog search' do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)

    get '/', params: { q: 'frogs', search_field: 'search' }
    get '/articles', params: { q: 'frogs', f: { eds_search_limiters_facet: ['Direct access to full text'] } },
                     headers: { 'Accept' => 'application/json' }
    get '/view/3402192'

    link = Capybara::Node::Simple.new(response.body).find_link('Search results')
    expect(link[:href]).to start_with('/?').and include('search_field=search')
  end

  it 'returns to the articles search' do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
    stub_article_service(type: :single, docs: [EdsDocument.new(id: '123', eds_title: 'My Title')])

    get '/articles', params: { q: 'frogs', search_field: 'search' }
    get '/catalog', params: { q: 'frogs' }, headers: { 'Accept' => 'application/json' }
    get '/articles/123'

    link = Capybara::Node::Simple.new(response.body).find_link('Search results')
    expect(link[:href]).to start_with('/articles?').and include('search_field=search')
  end
end
