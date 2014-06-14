require "spec_helper"

describe "Library location hours", feature: true, js: true, :"data-integration" => true do
  it "should display today's hours" do
    visit catalog_path("10365287")
    within "div.location-hours-today" do
      expect(page).to have_content("Today's hours:")
    end
  end
end
