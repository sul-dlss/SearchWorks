# encoding: UTF-8
require "spec_helper"

feature "Home Page" do
  before do
    visit root_path
  end
  scenario "facets should display" do
    expect(page).to have_title("SearchWorks : Stanford University Libraries catalog")
    expect(page).to have_css('h2', text: "Find materials by…")
    expect(page).to have_css(".panel-heading", text: "Resource type")
    expect(page).to have_css(".panel-heading", text: "Access")
    expect(page).to have_css(".panel-heading", text: "Library")
  end
  scenario "'Featured sets' section should display" do
    expect(page).to have_css(".media a", text: "Digital collections")
    expect(page).to have_css(".media a", text: "Dissertations & theses")
    expect(page).to have_css(".media a", text: "Selected article databases")
    expect(page).to have_css(".media a", text: "Course reserves")
  end
  scenario "'Featured sets' images should be clickable", js: true do
    within('.features') do
      all('[data-no-link-href]').last.click
      expect(current_url).to match /#{course_reserves_path}$/
    end
  end
  scenario "'Articles' section should display" do
    expect(page).to have_css('h2', text: 'Articles')
    expect(page).to have_css(".media a", text: "xSearch")
    expect(page).to have_css(".media a", text: "Citation finder")
  end
  scenario "'Help with SearchWorks' section should display" do
    expect(page).to have_css('h2', text: 'Help with SearchWorks')
    expect(page).to have_css(".media a", text: "SearchWorks basics")
    expect(page).to have_css(".media a", text: "Advanced search")
  end
  scenario "Logo and catalog images should display" do
    expect(page).to have_css("a.navbar-brand img[alt=SearchWorks]")
    expect(page).to have_css("p.navbar-text.search-target img[alt=catalog]")
  end
  scenario "there should be no more link on any facets" do
    expect(page).to_not have_css('a', text: /more/)
  end
  scenario "should have the library facet hidden by default", js: true do
    within(".blacklight-building_facet") do
      expect(page).to have_css(".panel-title", text: "Library")
      expect(page).to_not have_css('li a', visible: true)
    end
  end
end
