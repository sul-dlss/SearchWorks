require 'spec_helper'

feature "Zero results" do
  scenario "should have no results and prompt to search all fields" do
    visit root_url
    fill_in "q", with: "sdfsda"
    select 'Author', from: 'search_field'
    click_button 'search'
    within "#content" do
      expect(page).to have_css("li", text: "Your search: Author: sdfsda")
      expect(page).to have_css("li", text: "Search all fields: All fields: sdfsda")
      expect(page).to have_css("a", text: "All fields: sdfsda")
    end
  end
  scenario "should have no results and prompt to remove limit" do
    visit root_url
    click_link "Book"
    fill_in "q", with: "sdfsda"
    click_button 'search'
    within "#content" do
      expect(page).to have_css("li", text: "Your search: All fields: sdfsda Resource type: Book")
      expect(page).to have_css("li", text: "Remove limit(s): All fields: sdfsda")
      expect(page).to have_css("a", text: "All fields: sdfsda")
    end
  end
end
