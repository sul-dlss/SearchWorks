require 'spec_helper'

feature "Backend lookup", js: true do
  before do
    visit root_path
    fill_in "q", with: "sdfsda"
    select 'Author', from: 'search_field'
    click_button 'search'
  end
  scenario "lookup should return additional results" do
    within "#content" do
      expect(page).to have_css("a", text: "All fields: sdfsda ... found 0 results")
    end
  end
end
