# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Search Results Page" do
  before do
    visit solr_document_path 11
  end

  it "has a masthead with the correct text" do
    expect(page).to have_css('.masthead', text: 'SearchWorks Catalog')
  end

  scenario "should have correct page title" do
    expect(page).to have_title("Amet ad & adipisicing ex mollit pariatur minim dolore. in SearchWorks catalog")
  end
  scenario "should have the vernacular title" do
    expect(page).to have_css('.vernacular-title', text: 'Currently, to obtain more information from the weakness of the resultant pain.')
  end
end
