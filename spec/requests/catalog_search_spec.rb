# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searching catalog' do
  before do
    stub_request(:get, 'https://searchworks.stanford.edu/?format=json&q=frog&rows=3')
      .to_return(status: 200, body:, headers: {})
  end

  let(:body) { JSON.dump({ response: { docs: [], pages: { total_count: 0 } } }) }

  it 'draws the page' do
    get '/all/catalog?q=frog'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('<turbo-frame id="catalog_module">')
  end
end
