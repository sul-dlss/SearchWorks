require "spec_helper"

describe "Databases Access Point", feature: true, :"data-integration" => true do
  it "should be present when selecting the databases facet" do
    visit root_url
    within("#facet-format") do
      click_link "Database"
    end
    within("#masthead") do
      expect(page).to have_css("h1", text: "Databases")
    end
  end
end