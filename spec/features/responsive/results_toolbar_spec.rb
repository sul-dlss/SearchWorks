# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Responsive results toolbar", :feature, :js do
  describe "desktop view (> 992px)" do
    it "displays correct tools" do
      visit root_path
      fill_in "q", with: ''
      click_button 'search'

      within '.page_links' do
        expect(page).to have_link("Next", visible: true)
        expect(page).to have_no_link("Previous", visible: true)
      end

      within ".sort-and-per-page" do
        expect(page).to have_css(".btn", text: "Sort by relevance", visible: true)
        expect(page).to have_css(".btn", text: "20 per page", visible: true)
      end
    end
  end

  describe "tablet view (768px - 992px) - ", :responsive, page_width: 800 do
    it "displays correct tools" do
      visit root_path
      fill_in "q", with: ''
      click_button 'search'

      within '.page_links' do
        expect(page).to have_link("Next", visible: true)
        expect(page).to have_no_link("Previous", visible: true)
      end
      within ".sort-and-per-page" do
        expect(page).to have_css(".btn", text: "20", visible: true)
      end
    end
  end

  describe "mobile landscape view (480px - 767px) - ", :responsive, page_width: 700 do
    it "display correct tools" do
      visit root_path
      fill_in "q", with: ''
      click_button 'search'

      within '.page_links' do
        expect(page).to have_link("Next", visible: true)
        expect(page).to have_no_link("Previous", visible: true)
      end

      within ".sort-and-per-page" do
        expect(page).to have_css("button", text: "20", visible: true)
      end
    end
  end
end
