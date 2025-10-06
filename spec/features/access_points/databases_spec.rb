# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Databases Access Point" do
  before do
    visit root_path
  end

  scenario "searching for a particular database" do
    within '.features' do
      click_link "Databases"
    end

    expect(page).to have_title "Databases in SearchWorks catalog"
    within(".search-area-bg") do
      expect(page).to have_css "h1", text: "Databases"
      expect(page).to have_link "Publication Finder"
      expect(page).to have_link "Articles+"
      expect(page).to have_link "Off-campus access"
    end
    expect(page).to have_link "Back to catalog search"
    expect(page).to have_text "Popular Databases"

    fill_in "search for", with: "Database"
    click_button "Search"

    expect(page).to have_link "Selected Database 4"

    expect(page).to have_text "Popular Databases"
  end

  scenario "searching for a particular database, but no results" do
    within '.features' do
      click_link "Databases"
    end

    expect(page).to have_title "Databases in SearchWorks catalog"

    fill_in "search for", with: "foo"
    click_button "Search"

    expect(page).to have_text "No results found"
  end

  scenario "searching for a particular topic", :js, :responsive, page_width: 1400 do
    visit databases_path

    fill_in "search for", with: "biolo"
    click_link 'Biology'

    expect(page).to have_link "Web of science core collection"
    within('aside') do
      expect(page).to have_text "Popular Databases"
      expect(page).to have_link "research.ebsco.com"
    end
  end
end
