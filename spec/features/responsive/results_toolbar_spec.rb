require "spec_helper"

describe "Responsive results toolbar", js: true, feature: true do
  before do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'
  end
  describe " - desktop view (> 980px)" do
    it "should display correct tools" do
      within "#sortAndPerPage" do
        expect(page).to_not have_css("#search-results-toolbar", visible: true)
      end
    end
  end
  describe " - tablet view (768px - 980px) - " do
    it "should display correct tools" do
      within "#sortAndPerPage" do
        page.driver.resize("800", "800")
        expect(page).to_not have_css("#search-results-toolbar", visible: true)
      end
    end
  end
  describe " - mobile landscape view (480px - 767px) - " do
    it "should display correct tools" do
      page.driver.resize("700", "700")
      within "#sortAndPerPage" do
        find("button.navbar-toggle").click
        within "#search-results-toolbar" do
          expect(page).to have_css("li a", text: "Relevance", visible: true)
          expect(page).to have_css("li a", text: "10", visible: true)
          expect(page).to have_css("li a", text: "All on this page", visible: true)
        end
      end
    end
  end
end
