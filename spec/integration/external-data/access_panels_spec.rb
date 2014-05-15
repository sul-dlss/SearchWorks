require "spec_helper"

describe "Access Panels", feature: true, :"data-integration" => true do
  describe "Online" do
    it "should not be displayed for objects without fulltext links" do
      visit catalog_path('10365287')
      expect(page).not_to have_css(".panel-online")
    end
    it "should be displayed for objects with fulltext links" do
      visit catalog_path('8436430')

      within(".panel-online") do
        within("ul.links") do
          expect(page).to have_css("li a", text: "purl.access.gpo.gov")
        end
      end
    end
  end
end
