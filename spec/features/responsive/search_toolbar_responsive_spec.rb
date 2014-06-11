require "spec_helper"

describe "Responsive search bar", js: true, feature: true do
  before do
    visit root_path
    first("#q").set ''
    click_button 'search'
  end
  describe " - desktop view (> 980px)" do
    it "should display correct tools" do
      within "#search-navbar" do
        expect(page).to_not have_css("#searchbar-navbar-collapse", visible: true)
      end
    end
  end
  describe " - tablet view (768px - 980px) - " do
    it "should display correct tools" do
      within "#search-navbar" do
        page.driver.resize("800", "800")
        expect(page).to_not have_css("#searchbar-navbar-collapse", visible: true)
      end
    end
  end
  describe " - mobile landscape view (480px - 767px) - " do
    it "should display correct tools" do
      page.driver.resize("700", "700")
      within "#search-navbar" do
        find("button.navbar-toggle").click
        within "#searchbar-navbar-collapse" do
          expect(page).to have_css("li a", text: "Advanced", visible: true)
          expect(page).to have_css("li.disabled a", text: "Browse", visible: true)
          expect(page).to have_css("li.disabled a", text: "Selections", visible: true)
        end
      end
    end
  end
end
