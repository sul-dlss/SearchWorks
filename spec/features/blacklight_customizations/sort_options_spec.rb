# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Sort options" do
  scenario "includes our custom options" do
    visit root_path
    fill_in 'q', with: ''
    click_button 'search'

    within '#sort-dropdown' do
      expect(page).to have_css("a.dropdown-item", text: 'relevance')
      expect(page).to have_css("a.dropdown-item", text: 'year (new to old)')
      expect(page).to have_css("a.dropdown-item", text: 'year (old to new)')
      expect(page).to have_css("a.dropdown-item", text: 'author')
      expect(page).to have_css("a.dropdown-item", text: 'title')
    end
  end
end
