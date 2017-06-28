require "spec_helper"

describe "Responsive search bar", js: true, feature: true do
  before do
    visit root_path
    first("#q").set ''
    click_button 'search'
  end
  describe " - desktop view (> 980px)" do
    it "displays the search form" do
      within "#search-navbar" do
        expect(page).to have_css(".search-form", visible: true)
      end
    end
  end
  describe " - tablet view (768px - 980px) - " do
    it "displays the search form" do
      within "#search-navbar" do
        page.driver.resize("800", "800")
        expect(page).to have_css(".search-form", visible: true)
      end
    end
  end
  describe " - mobile landscape view (480px - 767px) - " do
    it "displays the search form" do
      page.driver.resize("700", "700")
      within "#search-navbar" do
        expect(page).to have_css(".search-form", visible: true)
      end
    end
  end
end
