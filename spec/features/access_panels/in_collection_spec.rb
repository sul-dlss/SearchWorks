require "spec_helper"

feature "In collection Access Panel" do
  scenario "for MODS derived documents" do
    visit catalog_path('mf774fs2413')

    within(".panel-in-collection") do
      within(".panel-heading") do
        expect(page).to have_content("In collection")
      end
      within('.panel-body') do
        expect(page).to have_css("h4 a", text: "Image Collection1")
        expect(page).to have_css("[data-behavior='truncate']", text: /A collection of fixture images/)
      end
      within(".panel-footer") do
        expect(page).to have_css("dt", text: "Digital content")
        expect(page).to have_css("dd a", text: /\d+ items?/)
        expect(page).to have_css("dt", text: "Finding aid")
        expect(page).to have_css("dd a", text: "Online Archive of California")
        expect(page).to have_css("dt", text: "Collection PURL")
        expect(page).to have_css("dd a", text: "http://purl.stanford.edu/29")
      end
    end
  end
end
