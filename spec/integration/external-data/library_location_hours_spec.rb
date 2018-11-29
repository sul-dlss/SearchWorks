require "spec_helper"

describe "Library location hours", feature: true, js: true, "data-integration": true do
  it "should display today's hours" do
    visit solr_document_path("10365287")
    within "div.location-hours-today" do
      expect(page).to have_content("Today's hours:")
    end
  end
  it "should display an error message instead of today's hours for libraries that are not public accessible" do
    visit solr_document_path('407615')
    within "div.location-hours-today" do
      expect(page).not_to have_content("Today's hours:")
      expect(page).to have_content('No public access')
    end
  end
end
