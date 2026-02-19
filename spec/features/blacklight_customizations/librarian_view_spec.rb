# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Librarian View Customization", :js do
  it "MARC records should display" do
    visit solr_document_path('28')

    within(".tech-details") do
      expect(page).to have_content('Catkey: 28')

      click_link('Librarian view')
    end

    expect(page).to have_css('.modal-title', text: "Librarian View", visible: true)

    find('details:first-of-type > summary').click
    within("#marc_view") do
      expect(page).to have_css(".field", text: /Some intersting papers/)
    end
  end

  it "MODS records should display" do
    visit solr_document_path('bx988zq7071')

    within(".tech-details") do
      expect(page).to have_content('DRUID: bx988zq7071')

      click_link('Librarian view')
    end

    expect(page).to have_css('.modal-title', text: "Librarian View", visible: true)

    within(".cocina-view") do
      expect(page).to have_content("883 JPEG image files containing photographs")
    end
  end
end
