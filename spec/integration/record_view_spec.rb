require "spec_helper"

describe "Record view", feature: true do
  it "should display records from the index" do
    visit catalog_path("1")
    expect(page).to have_css("h1", text: "An object")
  end
end