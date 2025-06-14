# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Selections Path" do
  scenario "renders bookmarks page" do
    visit bookmarks_path
    expect(page).to have_css('h2', text: '0 catalog items')
    expect(page).to have_css('a', text: '0 articles+ items')
    expect(page).to have_css("h3", text: "You have no selections")
  end

  scenario "renders some bookmarks and toolbar", :js do
    skip('Passes locally, not on Travis.') if ENV['CI']
    visit search_catalog_path f: { format: ["Book"] }, view: "default"
    page.first('.toggle-bookmark-label').click
    page.all('.toggle-bookmark-label')[1].click
    expect(page).to have_css(".toggle-bookmark-label span", text: "Selected", count: 2)
    visit bookmarks_path
    expect(page).to have_css('h2', text: '2 catalog items')
    expect(page).to have_css('a', text: '0 articles+ items')
    within "#documents" do
      expect(page).to have_css("h3.index_title a", count: 2)
    end
    within ".sort-and-per-page" do
      expect(page).to have_link "Cite 1 - 2"
      expect(page).to have_button "Send 1 - 2"
      expect(page).to have_no_button "#select_all-dropdown"
    end
  end
end
