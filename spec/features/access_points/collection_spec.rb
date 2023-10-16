require 'rails_helper'

RSpec.feature "Collection Access Point" do
  before do
    visit search_catalog_path({ f: { collection: ["29"] } })
  end

  scenario "Access point masthead should be visible with 1 course reserve document" do
    expect(page).to have_title("Image Collection1 Collection in SearchWorks catalog")
    within("#masthead") do
      expect(page).to have_css("h1", text: "Image Collection1")
      expect(page).to have_css("div", text: "A collection of fixture images from the SearchWorks development index.")
      expect(page).to have_css('dt', text: 'Digital collection')
      expect(page).to have_css('dd', text: '1 digital item')
      expect(page).to have_css("dt", text: "Finding aid")
      expect(page).to have_css("dd a", text: "Online Archive of California")
    end
    within("#content") do
      expect(page).to have_css("div.document", count: 1)
    end
  end
end
