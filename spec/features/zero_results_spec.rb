require 'spec_helper'

feature "Zero results" do
  scenario "should have no results and prompt to search all fields" do
    visit root_url
    fill_in "q", with: "sdfsda"
    select 'Author/Contributor', from: 'search_field'
    click_button 'search'
    within "#content" do
      expect(page).to have_css('dt', text: 'Your current search')
      expect(page).to have_css('dd', text: 'Author/Contributor > sdfsda')
      expect(page).to have_css('dt', text: 'Search all fields')
      expect(page).to have_css('dd', text: 'sdfsda')
      expect(page).to have_css('a', text: 'sdfsda')
    end
  end
  scenario "should have no results and show correct link from advanced search", js: true do
    visit blacklight_advanced_search_engine.advanced_search_path
    fill_in "search_title", with: "sdfsda"
    click_button 'advanced-search-submit'
    within "#content" do
      expect(page).to have_css("li", text: I18n.t('blacklight.search.zero_results.limit'))
      expect(page).to have_css("a", text: I18n.t('blacklight.search.zero_results.return_to_advanced_search'))
    end
  end
  scenario "should have no results and prompt to remove limit" do
    visit root_url
    click_link "Book"
    fill_in "q", with: "sdfsda"
    click_button 'search'
    within "#content" do
      expect(page).to have_css('dt', text: 'Your current search')
      expect(page).to have_css('dd', text: 'sdfsda + Resource type > Book')
      expect(page).to have_css('dt', text: 'Remove limit(s)')
      expect(page).to have_css('dd', text: 'All fields > sdfsda')
      expect(page).to have_css('a', text: 'All fields > sdfsda')
    end
  end
end
