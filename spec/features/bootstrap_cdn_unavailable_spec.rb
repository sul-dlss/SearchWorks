# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'When the Bootstrap CDN is unavailable', :js do
  let(:browser) { page.driver.browser }
  # Record uncaught errors, and flag the page once every turbo:load handler (e.g. Blacklight.onLoad) has run
  let!(:error_recorder) do
    browser.execute_cdp('Page.addScriptToEvaluateOnNewDocument', source: <<~JS)
      window.jsErrors = []
      window.addEventListener("error", (e) => window.jsErrors.push(e.message))
      document.addEventListener("turbo:load", () => setTimeout(() => document.documentElement.dataset.loaded = "true"))
    JS
  end

  before do
    stub_article_service(docs: [])

    browser.execute_cdp('Network.enable')
    browser.execute_cdp('Network.setBlockedURLs', urls: ['*cdn.jsdelivr.net/npm/bootstrap@*'])
  end

  after do
    browser.execute_cdp('Network.setBlockedURLs', urls: [])
    browser.execute_cdp('Page.removeScriptToEvaluateOnNewDocument', identifier: error_recorder['identifier'])
  end

  it 'does not raise errors setting up popovers' do
    visit search_catalog_path(q: 'zzzzzzzzzzzzzz')

    expect(page).to have_css('html[data-loaded]')
    expect(page).to have_button 'Stanford-only'
    expect(page.evaluate_script('typeof bootstrap')).to eq 'undefined'
    expect(page.evaluate_script('window.jsErrors')).to be_empty
  end
end
