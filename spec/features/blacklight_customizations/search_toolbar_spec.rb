# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Search toolbar", :feature, :js do
  describe "Selections dropdown" do
    describe "show list" do
      it "navigates to selections page" do
        visit bookmarks_path
        expect(page).to have_css('h2', text: '0 catalog items')
        expect(page).to have_css('a', text: '0 articles+ items')
        expect(page).to have_css("h3", text: "You have no selections")
      end
    end

    describe "clear list" do
      it "clears selections and update selections count and recently added list" do
        skip 'Not working correctly'
        visit search_catalog_path f: { format: ["Book"] }, view: "default"
        expect(page).to have_css("li a", text: /SELECTIONS \(0\)/i)
        click_link "Selections"
        expect(page).to have_css("li#show-list.disabled")
        expect(page).to have_css("li#clear-list.disabled")
        page.first('label.toggle-bookmark').click
        expect(page).to have_css("li a", text: /SELECTIONS \(1\)/i)
        click_link "Selections"
        expect(page).to have_css("li.dropdown-list-title", count: 1)
        page.all('label.toggle-bookmark')[1].click
        expect(page).to have_css("li a", text: /SELECTIONS \(2\)/i)
        click_link "Selections"
        expect(page).to have_css("li.dropdown-list-title", count: 2)
        page.all('label.toggle-bookmark')[1].click
        expect(page).to have_css("li a", text: /SELECTIONS \(1\)/i)
        click_link "Selections"
        expect(page).to have_css("li.dropdown-list-title", count: 1)
        click_link "Selections"
        expect(page).to have_css("label.toggle-bookmark", text: "Selected", count: 1)
        click_link "Selections"
        click_link "Clear all lists"
        expect(page).to have_css("div.alert.alert-success", text: "Your selections have been deleted.")
        expect(page).to have_css("h2", text: "Refine your results")
      end
    end
  end
end