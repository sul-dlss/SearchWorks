# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Search Results Page" do
  scenario "should have correct page title" do
    visit search_catalog_path f: { format: ["Book"] }
    expect(page).to have_title(/.*\d (result|results) in SearchWorks catalog/)
  end
  scenario "vernacular title" do
    visit search_catalog_path(q: '11')

    within(first('.document')) do
      expect(page).to have_css('h3', text: "Amet ad & adipisicing ex mollit pariatur minim dolore.")
      within('.document-metadata') do
        expect(page).to have_css('li', text: 'Currently, to obtain more information from the weakness of the resultant pain.')
      end
    end
  end
end
