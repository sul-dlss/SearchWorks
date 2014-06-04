require 'spec_helper'

feature "Zero results" do
  scenario "should have no results and ask to remove search field" do
    visit root_url
    fill_in "q", with: "sdfsda"
    select 'Author', from: 'search_field'
    click_button 'search'
    within "#content" do
      expect(page).to have_css("li", text: "you searched by Author - try searching everything")
      expect(page).to have_css("a", text: "try searching everything")
    end
  end
  scenario "should have no results and ask to remove search field" do
    visit root_url
    click_link "Book"
    fill_in "q", with: "sdfsda"
    click_button 'search'
    within "#content" do
      expect(page).to have_css("li", text: "you limited your search by Resource type - try removing limits")
      expect(page).to have_css("a", text: "try removing limits")
    end
  end
end
