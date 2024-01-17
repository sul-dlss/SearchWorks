require 'rails_helper'

RSpec.describe "Responsive search bar", :feature, :js do
  describe " - desktop view (> 980px)" do
    it "displays the search form" do
      visit root_path
      first("#q").set ''
      click_button 'search'

      within "#search-navbar" do
        expect(page).to have_css(".search-form", visible: true)
      end
    end
  end

  describe " - tablet view (768px - 980px) - ", :responsive, page_width: 800 do
    it "displays the search form" do
      visit root_path
      first("#q").set ''
      click_button 'search'

      within "#search-navbar" do
        expect(page).to have_css(".search-form", visible: true)
      end
    end
  end

  describe " - mobile landscape view (480px - 767px) - ", :responsive, page_width: 700 do
    it "displays the search form" do
      visit root_path
      first("#q").set ''
      click_button 'search'

      within "#search-navbar" do
        expect(page).to have_css(".search-form", visible: true)
      end
    end
  end
end
