require "spec_helper"

describe "Record view", feature: true, :"data-integration" => true do
  it "should display records from the index" do
    visit catalog_path("2818067")
    expect(page).to have_css("h1", text: "10 kW power electronics for hydrogen arcjets [microform]")
  end
end