# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Legacy format parameter mapping' do
  it 'maps legacy formats and preserves current formats' do
    get '/?f[format_main_ssim][]=Music%20recording&f[format_hsim][]=Book&f[building_facet][]=Business'

    redirect_params = Rack::Utils.parse_nested_query(URI.parse(response.location).query)

    expect(redirect_params.dig('f', 'format_hsim')).to eq ['Book', 'Sound recording']
  end

  it 'rejects an indexed format facet value' do
    get '/catalog.rss?f%5Bformat_main_ssim%5D%5B0%5D=Database'

    expect(response).to have_http_status(:bad_request)
  end
end
