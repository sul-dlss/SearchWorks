require "spec_helper"

describe "Responsive Home Page", feature: true, js: true do
  describe "facets" do
    before do
      visit root_path
    end
    it "should show the facets on large screens" do
      within(".blacklight-format_main_ssim") do
        expect(page).to have_css(".panel-title", text: "Resource type")
        within("ul.facet-values") do
          expect(page).to have_css("li a", text: "Book", visible: true)
          expect(page).to have_css("li a", text: "Newspaper", visible: true)
        end
      end

      page.driver.resize("700", "700")

      within(".blacklight-format_main_ssim") do
        expect(page).to have_css(".panel-title", text: "Resource type")
        expect(page).not_to have_css("li a", text: "Book", visible: true)
        expect(page).not_to have_css("li a", text: "Newspaper", visible: true)
      end
    end
  end
end
