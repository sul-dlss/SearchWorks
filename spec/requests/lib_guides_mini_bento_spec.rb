# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mini-bento endpoint for library guides' do
  before do
    stub_request(:get, 'https://example.com/1.1/guides?key=abc1234&search_terms=frog&site_id=123456&sort_by=relevance&status=1')
      .to_return(status: 200, body:, headers: {})
  end

  let(:body) { JSON.dump(response_list) }
  let(:response_list) { Array.new(100) { response_hash.dup } }
  let(:response_hash) { { name: 'name' } }

  it 'draws the page' do
    get '/all/xhr_search/libguides.json?q=frog'
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq({
                                         'app_link' => 'https://guides.library.stanford.edu/srch.php?q=frog',
                                         'total' => '100+'
                                       })
  end
end
