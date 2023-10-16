require 'rails_helper'

RSpec.feature "Search Results Page" do
  before do
    visit solr_document_path 11
  end

  scenario "should have correct page title" do
    expect(page).to have_title("Amet ad & adipisicing ex mollit pariatur minim dolore. in SearchWorks catalog")
  end
  scenario "should have the vernacular title" do
    expect(page).to have_css('.vernacular-title', text: 'Currently, to obtain more information from the weakness of the resultant pain.')
  end
  scenario "should have resource type icon" do
    within '.document' do
      expect(page).to have_css('h1 span.sul-icon')
    end
  end
end
