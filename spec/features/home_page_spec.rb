require "spec_helper"

feature "Home Page" do
  before do
    visit root_path
  end
  scenario "facets should display" do
    expect(page).to have_title("SearchWorks : Stanford University Libraries catalog")
    expect(page).to have_css(".panel-heading", text: "Resource type")
    expect(page).to have_css(".panel-heading", text: "Access")
    expect(page).to have_css(".panel-heading", text: "Library")
  end
  scenario "featured sets" do
    expect(page).to have_css("li .media-heading", text: "Digital collections")
    expect(page).to have_css("li .media-heading", text: "Dissertations, theses, student work")
    expect(page).to have_css("li .media-heading", text: "Selected databases")
    expect(page).to have_css("li .media-heading", text: "Music search")
  end
  scenario "searching for articles" do
    expect(page).to have_css("li .media-heading", text: "xSearch")
    expect(page).to have_css("li .media-heading", text: "eJournals")
  end
end
