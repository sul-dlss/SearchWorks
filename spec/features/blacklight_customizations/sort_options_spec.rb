require "spec_helper"

RSpec.feature "Sort options" do
  scenario "should include our custom options" do
    visit root_path
    fill_in 'q', with: ''
    click_button 'search'

    within '#sort-dropdown' do
      expect(page).to have_css("li a", text: 'relevance')
      expect(page).to have_css("li a", text: 'year (new to old)')
      expect(page).to have_css("li a", text: 'year (old to new)')
      expect(page).to have_css("li a", text: 'author')
      expect(page).to have_css("li a", text: 'title')
    end
  end
end
