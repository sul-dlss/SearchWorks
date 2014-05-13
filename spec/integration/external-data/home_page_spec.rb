require "spec_helper"

describe "Home Page", feature: true, :"data-integration" => true do
  before do
    visit root_path
  end
  describe "facets" do
    it "should display the Resource type" do
      pending("This facet is not in the data-integration index yet")
      within(".blacklight-format_main_ssim") do
        expect(page).to have_css(".panel-title", text: "Resource type")
        within("ul.facet-values") do
          expect(page).to have_css("li a", text: "Book")
          expect(page).to have_css("li a", text: "Newspaper")
        end
      end
    end
    it "should display the Access" do
      within(".blacklight-access_facet") do
        expect(page).to have_css(".panel-title", text: "Access")
        within("ul.facet-values") do
          expect(page).to have_css("li a", text: "Online")
          expect(page).to have_css("li a", text: "At the Library")
        end
      end
    end
    it "should display the Library" do
      within(".blacklight-building_facet") do
        expect(page).to have_css(".panel-title", text: "Library")
        within("ul.facet-values") do
          expect(page).to have_css("li a", text: "Green")
          expect(page).to have_css("li a", text: "SAL3 (off-campus storage)")
        end
      end
    end
  end
end