# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Checking the asset version' do
  it 'returns the current server revision as json' do
    allow(Settings).to receive(:REVISION).and_return('abc123')

    get '/asset_version'

    expect(response).to have_http_status :ok
    expect(response.parsed_body).to eq('revision' => 'abc123')
  end

  it 'instructs clients not to cache the response' do
    get '/asset_version'

    expect(response.headers['Cache-Control']).to eq 'no-store'
  end
end
