# encoding: UTF-8

require 'spec_helper'

feature "Results Toolbar", js: true do
  scenario "should have desktop tools visible" do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'

    within "#sortAndPerPage" do
      within "div.page_links" do
        expect(page).to have_css("a.btn.btn-sul-toolbar.disabled", text: /Previous/, visible: true)
        expect(page).to have_css("span.page_entries", text: /1 - 20/, visible: true)
        expect(page).to have_css("a.btn.btn-sul-toolbar", text: /Next/, visible: true)
      end
      expect(page).to have_css("div#view-type-dropdown button.dropdown-toggle")
      expect(page).to have_css("div#sort-dropdown", text: "Sort by relevance", visible: true)
      expect(page).to have_css("#select_all-dropdown", text: "Select all")
      expect(page).to_not have_css("a", text: /Cite/)
      expect(page).to_not have_css("button", text: /Send/)
    end
  end
  scenario "pagination links for single items should not have any number of results info" do
    visit root_path
    fill_in "q", with: '24'
    click_button 'search'

    within('.sul-toolbar') do
      expect(page).to_not have_css('.page_links')
      expect(page).to_not have_content('1 entry')
    end
  end
  scenario "pagination links for multiple items but no pages should not have any number of results info" do
    visit root_path
    fill_in "q", with: '34'
    click_button 'search'

    expect(page).to have_css('h2', text: '4 results')

    within('.sul-toolbar') do
      expect(page).to_not have_css('.page_links')
      expect(page).to_not have_content('1 - 4')
    end
  end
end
