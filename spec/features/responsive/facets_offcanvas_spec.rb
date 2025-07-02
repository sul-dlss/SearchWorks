# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Responsive facets offcanvas", :feature, :js do
  describe "mobile view (≤ 767px)", :responsive, page_width: 500 do
    before do
      visit root_path
      fill_in "q", with: ''
      click_button 'search'
      find("a[role='button']", text: "Filters").click
    end

    it "renders the Top filters title in offcanvas" do
      within ".offcanvas .top-filters" do
        expect(page).to have_css("h2", text: "Top filters", visible: :visible)
      end
    end

    it "renders the Other filters title in offcanvas" do
      within ".offcanvas .other-filters" do
        expect(page).to have_css("h2", text: "Other filters", visible: :visible)
      end
    end

    it "shows facet values under Top filters" do
      within ".offcanvas .top-filters" do
        expect(page).to have_css(".facet-limit", visible: :visible)
      end
    end

    it "shows facet values under Other filters" do
      within ".offcanvas .other-filters" do
        expect(page).to have_css(".facet-limit", visible: :visible)
      end
    end
  end
end
