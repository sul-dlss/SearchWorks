# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Merged Images" do
  scenario "in search results" do
    visit root_path
    fill_in 'q', with: '37'
    click_button 'search'

    expect(page).to have_css("h3 a", text: "Merged Image1") # Title
    expect(page).to have_css(".main-title-date", text: "[2004 - ]") # Main title date
    expect(page).to have_css("ul.document-metadata") # metadata items
  end
  scenario "record view" do
    visit solr_document_path('37')

    expect(page).to have_css("h1", text: "Merged Image1") # Title
    within(".panel-in-collection") do # In Collection Access Panel
      expect(page).to have_css(".card-body a", text: "Merged Image Collection1")
    end
    # Metadata sections
    expect(page).to have_css('h3', text: "Contents/Summary")
    expect(page).to have_css('h3', text: "Subjects")
    expect(page).to have_css('h3', text: "Bibliographic information")
  end
end
