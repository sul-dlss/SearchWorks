# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Zero results" do
  scenario "getting no results from the catalog search" do
    visit root_url
    fill_in "q", with: "sdfsda"
    select 'Author/Contributor', from: 'search_field'
    click_button 'search'
    expect(page).to have_css("h2", text: "Modify your search")
    expect(page).to have_link 'sdfsda'
  end

  scenario "getting no results from advanced search", :js do
    visit blacklight_advanced_search_engine.advanced_search_path
    fill_in "Title", with: "sdfsda"
    click_button 'advanced-search-submit'
    expect(page).to have_link I18n.t('blacklight.search.zero_results.return_to_advanced_search')
  end
end
