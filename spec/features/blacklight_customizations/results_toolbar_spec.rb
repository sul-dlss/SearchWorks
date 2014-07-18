# encoding: UTF-8

require 'spec_helper'

feature "Results Toolbar", js: true do
  before do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'
  end
  scenario "should have desktop tools visible" do
    within "#sortAndPerPage" do
      within "div.page_links" do
        expect(page).to have_css("a.btn.btn-sul-toolbar.disabled", text: /Previous/, visible: true)
        expect(page).to have_css("span.page_entries", text: /1 - 20/, visible: true)
        expect(page).to have_css("a.btn.btn-sul-toolbar", text: /Next/, visible: true)
      end
      expect(page).to have_css("div#view-type-dropdown a")
      expect(page).to have_css("div#sort-dropdown", text: "Sort by relevance", visible: true)
      expect(page).to have_css("#select_all-dropdown", text: "Select all")
      expect(page).to_not have_css("a", text: /Cite/)
      expect(page).to_not have_css("button", text: /Send/)
    end
  end
end
