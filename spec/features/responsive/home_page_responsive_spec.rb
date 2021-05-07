require "spec_helper"

describe "Responsive Home Page", feature: true, js: true do
  describe "facets" do
    it "should show the facets on large screens" do
      visit root_path

      within(".blacklight-access_facet") do
        expect(page).to have_css(".card-header", text: "Access")
        within("ul.facet-values") do
          expect(page).to have_css("li a", text: "Online", visible: true)
          expect(page).to have_css("li a", text: "At the Library", visible: true)
        end
      end
    end

    it 'should collapse facets on small screens', responsive: true, page_width: 700 do
      visit root_path

      within(".blacklight-access_facet") do
        expect(page).to have_css(".card-header", text: "Access")
        expect(page).not_to have_css("li a", text: "Online", visible: true)
        expect(page).not_to have_css("li a", text: "At the Library", visible: true)
      end
    end
  end
end
