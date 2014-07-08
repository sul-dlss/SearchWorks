require "spec_helper"

feature "Search Results Page" do
  before do
    visit catalog_path 1
  end
  scenario "should have correct page title" do
    expect(page).to have_title("An object in SearchWorks")
  end
  scenario "should have resource type icon" do
    expect(page).to have_css("li span.sul-icon")
  end
end
