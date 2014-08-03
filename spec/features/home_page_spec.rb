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
  scenario "'Featured sets' section should display" do
    expect(page).to have_css(".thumbnail h3", text: "Digital collections")
    expect(page).to have_css(".thumbnail h3", text: "Dissertations & theses")
    expect(page).to have_css(".thumbnail h3", text: "Selected databases")
  end
  scenario "'Featured sets' images should be clickable", js: true do
    within('.features') do
      all('[data-no-link-href]').last.click
      expect(current_url).to match /#{selected_databases_path}$/
    end
  end
  scenario "'Searching for articles' section should display" do
    expect(page).to have_css("li .media-heading", text: "xSearch")
    expect(page).to have_css("li .media-heading", text: "eJournals")
  end
  scenario "Logo and catalog images should display" do
    expect(page).to have_css("a.navbar-brand img[alt=SearchWorks]")
    expect(page).to have_css("p.navbar-text.search-target img[alt=catalog]")
  end
  scenario "there should be no more link on any facets" do
    expect(page).to_not have_css('a', text: /more/)
  end
end
