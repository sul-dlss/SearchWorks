require "spec_helper"

describe "Responsive Home Page", feature: true, js: true do
  describe "facets" do
    before do
      visit root_path
    end
    it "should show the facets on large screens" do
      within(".blacklight-access_facet") do
        expect(page).to have_css(".panel-title", text: "Access")
        within("ul.facet-values") do
          expect(page).to have_css("li a", text: "Online", visible: true)
          expect(page).to have_css("li a", text: "At the Library", visible: true)
        end
      end

      page.driver.resize("700", "700")

      within(".blacklight-access_facet") do
        expect(page).to have_css(".panel-title", text: "Access")
        expect(page).not_to have_css("li a", text: "Online", visible: true)
        expect(page).not_to have_css("li a", text: "At the Library", visible: true)
      end
    end
  end
end
