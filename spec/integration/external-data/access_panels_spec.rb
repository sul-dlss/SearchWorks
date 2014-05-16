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

  describe "Course Reserve" do
    it "should not be displayed for non course reserve objects" do
      visit catalog_path('10473427')
      expect(page).not_to have_css(".panel-course-reserve")
    end
    it "should be displayed for course reserve objects" do
      visit catalog_path('10020587')

      within(".panel-course-reserve") do
        expect(page).to have_css("li a", text: "ACCT-212-01-02 -- Managerial Accounting: Base")
      end
    end
  end
end
