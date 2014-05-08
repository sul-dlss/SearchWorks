require 'spec_helper'

feature "Bookmarks Select/UnSelect Text" do
  before do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'
  end

  scenario "should have bookmarks text as select", js: true do
    within first("div.documentHeader") do
      within "label.toggle_bookmark" do
        expect(page).to have_css("span", text: "Select")
      end
    end
  end

  scenario "should have bookmarks text as selected", js: true do
    within first("div.documentHeader") do
      within "label.toggle_bookmark" do
        find(:css, '#toggle_bookmark_1').set(true)
        expect(page).to have_css("span", text: "Selected")
      end
    end
  end

end
