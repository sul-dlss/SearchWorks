# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/searchworks4/_search_navbar' do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:search_state) { Blacklight::SearchState.new({}, blacklight_config) }

  before do
    allow(view).to receive_messages(blacklight_config: blacklight_config, search_state: search_state,
                                    search_action_url: '/catalog',
                                    blacklight_configuration_context: Blacklight::Configuration::Context.new(controller))
    render
  end

  it 'puts the search mode radios under the analytics controller' do
    expect(rendered).to have_css('div[data-controller="analytics"][data-analytics-category-value="select_search_mode"]')
  end

  it 'tracks a change to either search mode radio' do
    expect(rendered).to have_css('#searchTypeCatalog[data-action="search-navbar#toggleMode analytics#trackEvent"]',
                                 visible: :all)
    expect(rendered).to have_css('#searchTypeArticle[data-action="search-navbar#toggleMode analytics#trackEvent"]',
                                 visible: :all)
  end
end
