require "spec_helper"

feature "Search Results Page" do
  before do
    visit catalog_index_path f: {format: ["Book"]}
  end
  scenario "should have correct page title" do
    expect(page).to have_title(/.*\d (result|results) in SearchWorks/)
  end
end
