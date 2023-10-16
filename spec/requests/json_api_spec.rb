# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'JSON API Responses' do
  it 'has augmmented documents using the JsonResultsDocumentPresenter' do
    get '/catalog', params: { q: '57', format: 'json' }
    documents = response.parsed_body.dig('response', 'docs')

    expect(documents.length).to be 1
    expect(documents.first['fulltext_link_html']).to be_present
    expect(documents.first['fulltext_link_html'].first).to include('sfx.example.com')
  end
end
