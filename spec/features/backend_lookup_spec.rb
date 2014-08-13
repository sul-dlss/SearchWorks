require 'spec_helper'

feature "Backend lookup", js: true do
  before do
    visit root_path
  end
  scenario "lookup should return additional results on the zero results page" do
    fill_in "q", with: "sdfsda"
    select 'Author', from: 'search_field'
    click_button 'search'

    within "#content" do
      expect(page).to have_css("a", text: "All fields: sdfsda ... found 0 results")
    end
  end
  scenario "lookup should return additional results on the results page" do
    click_link "Online"
    fill_in "q", with: '2'
    click_button 'search'

    within "#content" do
      expect(page).to have_css("a", text: "Remove limit(s) ... found 1 results")
    end
  end
end
