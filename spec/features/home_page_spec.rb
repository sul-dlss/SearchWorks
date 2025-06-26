# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Home Page" do
  before do
    visit root_path
  end

  scenario 'does not duplicate the search form' do
    expect(page).to have_no_css('#search-navbar')
  end

  scenario "facets should display" do
    expect(page).to have_title("SearchWorks catalog : Stanford Libraries")
    expect(page).to have_css(".accordion-header", text: "Resource type")
    expect(page).to have_css(".accordion-header", text: "Access")
    expect(page).to have_css(".accordion-header", text: "Library")
  end

  scenario "'Featured sets' section should display" do
    expect(page).to have_css(".features a", text: "Digital collections")
    expect(page).to have_css(".features a", text: "Theses & dissertations")
    expect(page).to have_css('.features a', text: 'Government documents')
    expect(page).to have_css(".features a", text: "Databases")
    expect(page).to have_css(".features a", text: "Course reserves")
  end

  scenario "Logo and catalog images should display" do
    expect(page).to have_css("a.navbar-brand")
  end

  scenario "there should be no more link on any facets" do
    within ('.home-page-facets') do
      expect(page).to have_no_css('a', text: /more/)
    end
  end

  scenario "should have the library facet hidden by default" do
    within(".blacklight-building_facet") do
      expect(page).to have_button 'Library'
      expect(page).to have_css('#facet-building_facet.collapse:not(.show)', visible: false)
    end
  end

  it 'has schema.org markup for searching' do
    expect(page).to have_css('script[type="application/ld+json"]', text: %r{http://schema.org}, visible: false)
  end

  it 'gathers analytics' do
    expect(page).to have_css('[data-controller="analytics"][data-action="hide.bs.collapse->analytics#trackFacetHide show.bs.collapse->analytics#trackFacetShow"]')
    within('.features') do
      expect(page).to have_css('[data-controller="analytics"] [data-action="click->analytics#trackLink"]', count: 5)
    end
  end
end
