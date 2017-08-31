# encoding: UTF-8
require "spec_helper"

feature "Home Page" do
  before do
    visit root_path
  end
  scenario "facets should display" do
    expect(page).to have_title("SearchWorks catalog : Stanford Libraries")
    expect(page).to have_css('h2', text: "Find materials by…")
    expect(page).to have_css(".panel-heading", text: "Resource type")
    expect(page).to have_css(".panel-heading", text: "Access")
    expect(page).to have_css(".panel-heading", text: "Library")
  end
  scenario "'Featured sets' section should display" do
    expect(page).to have_css(".features a", text: "Digital collections")
    expect(page).to have_css(".features a", text: "Theses & dissertations")
    expect(page).to have_css('.features a', text: 'Government documents')
    expect(page).to have_css(".features a", text: "Databases")
    expect(page).to have_css(".features a", text: "Course reserves")
  end
  scenario "'Featured sets' images should be clickable", js: true do
    within('.features') do
      all('[data-no-link-href]').last.click
      expect(current_url).to match /#{course_reserves_path}$/
    end
  end
  scenario "Logo and catalog images should display" do
    expect(page).to have_css("a.navbar-brand")
    expect(page).to have_css(".navbar-text.search-target", text: "catalog")
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
