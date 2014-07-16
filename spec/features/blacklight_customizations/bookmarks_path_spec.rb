require 'spec_helper'

feature "Selections Path" do

  scenario "should render bookmarks page" do
    visit selections_path
    expect(page).to have_css("h2", text: "0 selections")
    expect(page).to have_css("h3", text: "You have no bookmarks")
  end

  scenario "should render some bookmarks and toolbar", js: true do
    visit catalog_index_path f: {format: ["Book"]}, view: "default"
    page.all('label.toggle_bookmark')[0].click
    page.all('label.toggle_bookmark')[1].click
    expect(page).to have_css("label.toggle_bookmark span", text: "Selected", count: 2)
    visit selections_path
    expect(page).to have_css("h2", text: "2 selections")
    within "#documents" do
      expect(page).to have_css("h3.index_title a", count: 2)
    end
    within ".search-widgets" do
      expect(page).to have_css("a", text: "Cite 1 - 2")
      expect(page).to have_css("button", text: "Send 1 - 2")
      expect(page).to_not have_css("button#select_all-dropdown")
    end
  end
end
