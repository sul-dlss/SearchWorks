# encoding: UTF-8
require "spec_helper"

describe "Callnumber browse", js:true, feature: true, :"data-integration" => true do
  it "should have an embedded panel on the record page" do
    visit solr_document_path("9696118")
    within(".record-browse-nearby") do
      expect(page).to have_css("a", text: "PS3552 .E74 B4 2012")
      expect(page).to have_css("a", text: "Z239 .G75 B477 2012")
      click_link("Z239 .G75 B477 2012")
    end

    # Second embedded gallery documents and browse more elements
    expect(page).to have_css(".gallery-document", count: 27)
    expect(page).to have_css(".gallery-document a", text: "The Dickinson composites")
    expect(page).to have_css(".gallery-document a", text: "The Silverado squatters", visible: false)
    # Click previous
    page.find(".left.embed-browse-control").click
    expect(page).to have_css(".gallery-document a", text: "The Silverado squatters", visible: true)
    # Browse more links
    expect(page).to have_css(".gallery-document a", text: "Continue to full page", count: 2)
    click_link("Z239 .G75 B477 2012")
    expect(page).to have_css(".gallery-document", visible: false)

    # First embedded gallery documents
    click_link("PS3552 .E74 B4 2012")
    expect(page).to have_css(".gallery-document", count: 27)
    expect(page).to have_css(".gallery-document a", text: "A certain slant of sunlight")
    expect(page).to have_css(".gallery-document a", text: "Great stories of the chair", visible: false)
    # Click next
    page.find(".right.embed-browse-control").click
    expect(page).to have_css(".gallery-document a", text: "Great stories of the chair", visible: true)
    # Browse more links

    expect(page).to have_css(".gallery-document a", text: "Continue to full page", count: 2)
  end
end
