require 'rails_helper'

RSpec.feature "Search types" do
  scenario "should include our custom types" do
    visit root_path

    within('#search_field') do
      expect(page).to have_css('option[value="search"]',        text: 'All fields')
      expect(page).to have_css('option[value="search_title"]',  text: 'Title')
      expect(page).to have_css('option[value="search_author"]', text: 'Author')
      expect(page).to have_css('option[value="subject_terms"]', text: 'Subject')
      expect(page).to have_css('option[value="call_number"]',   text: 'Call number')
      expect(page).to have_css('option[value="search_series"]', text: 'Series')
    end
  end

  it 'should have different types for article search'
end
