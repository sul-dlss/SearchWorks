# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Aria Landmarks" do
  before do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'
  end

  scenario "should have aria landmarks" do
    expect(page).to have_xpath("//header[@id='topnav' and @role='banner']")
    expect(page).to have_xpath("//nav[@id='search-navbar']")
    expect(page).to have_xpath("//search/form")
    expect(page).to have_xpath("//main")
    expect(page).to have_xpath("//footer")
  end
end
