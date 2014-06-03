require "spec_helper"

feature "Collection Access Point" do
  before do
    visit catalog_index_path({f: {collection: ["29"] } } )
  end
  scenario "Access point masthead should be visible with 1 course reserve document" do
    within("#masthead") do
      expect(page).to have_css("h1", text: "Image Collection1")
      expect(page).to have_css("div", text: "A collection of fixture images from the SearchWorks development index.")
      expect(page).to have_css("dt", text: "DIGITAL CONTENT:")
      expect(page).to have_css("dd", text: "1 item")
    end
    within("#content") do
      expect(page).to have_css("div.document", count:1)
    end
  end
end
