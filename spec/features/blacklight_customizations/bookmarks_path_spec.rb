require 'rails_helper'

RSpec.feature "Selections Path" do
  scenario "renders bookmarks page" do
    visit bookmarks_path
    expect(page).to have_css('h2', text: '0 catalog items')
    expect(page).to have_css('a', text: '0 articles+ items')
    expect(page).to have_css("h3", text: "You have no selections")
  end

  scenario "renders some bookmarks and toolbar", js: true do
    skip('Passes locally, not on Travis.') if ENV['CI']
    visit search_catalog_path f: { format: ["Book"] }, view: "default"
    page.all('label.toggle-bookmark')[0].click
    page.all('label.toggle-bookmark')[1].click
    expect(page).to have_css("label.toggle-bookmark span", text: "Selected", count: 2)
    visit bookmarks_path
    expect(page).to have_css('h2', text: '2 catalog items')
    expect(page).to have_css('a', text: '0 articles+ items')
    within "#documents" do
      expect(page).to have_css("h3.index_title a", count: 2)
    end
    within ".search-widgets" do
      expect(page).to have_css("a", text: "Cite 1 - 2")
      expect(page).to have_css("button", text: "Send 1 - 2")
      expect(page).not_to have_css("button#select_all-dropdown")
    end
  end
end
