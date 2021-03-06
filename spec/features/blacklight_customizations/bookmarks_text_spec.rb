require 'spec_helper'

feature "Bookmarks Select/UnSelect Text", js: true do
  before do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'
  end

  scenario "should have bookmarks text as select" do
    within first("div.documentHeader") do
      within "label.toggle_bookmark" do
        expect(page).to have_css("span", text: "Select")
      end
    end
  end

  scenario "should have bookmarks text as selected" do
    within first("div.documentHeader") do
      check("Select")
    end
    within first("div.documentHeader") do
      expect(page).to have_css("span", text: "Selected", visible: true)
    end
  end
end
