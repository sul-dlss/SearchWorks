# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'application and dependency monitoring' do
  before do
    stub_request(:post, %r{^https?://.*/authn/login$})
      .with(
        body: /^{"username":"?.*"?,"password":"?.*"?}$/,
        headers: {
          'Accept' => 'application/json',
          'Connection' => 'close',
          'Content-Type' => 'application/json',
          'Host' => /.*/,
          'User-Agent' => 'FolioApiClient',
          'X-Okapi-Tenant' => 'sul'
        }
      )
      .to_return(headers: { 'x-okapi-token': 'tokentokentoken' }, status: 201)
  end

  it '/status checks if Rails app is running' do
    visit '/status'
    expect(page.status_code).to eq 200
    expect(page).to have_text('Application is running')
  end
  it 'Solr at /status/sw_solr runs' do
    visit '/status/sw_solr'
    expect(page.status_code).to eq 200
    expect(page).to have_text('sw_solr')
  end
  it '/status/all checks if required dependencies are ok and also shows non-crucial dependencies' do
    visit '/status/all'
    expect(page).to have_text('sw_solr') # required check
    # TODO: expect(page).to have_text('embed_url') # non-crucial check
  end
end
