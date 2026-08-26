# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomepageSearchComponent, type: :component do
  before do
    allow(vc_test_controller).to receive(:blacklight_config).and_return(blacklight_config)
    with_request_url '/' do
      render_inline(described_class.new(url: '/catalog', params: {}))
    end
  end

  let(:blacklight_config) { CatalogController.blacklight_config }

  it 'puts the search mode radios under the analytics controller' do
    expect(page).to have_css('div[data-controller="analytics"][data-analytics-category-value="select_search_mode"]')
  end

  it 'tracks a change to either search mode radio' do
    expect(page).to have_css('#searchTypeCatalog[data-action="home-page-search#toggle analytics#trackEvent"]', visible: :all)
    expect(page).to have_css('#searchTypeArticle[data-action="home-page-search#toggle analytics#trackEvent"]', visible: :all)
  end
end
