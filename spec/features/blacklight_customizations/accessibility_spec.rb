require 'rails_helper'

RSpec.feature "Aria Landmarks", js: true do
  before do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'
  end

  scenario "should have header landmark" do
    expect(page).to have_xpath("//header[@id='topnav' and @role='banner']")
  end

  scenario "should have feedback landmark" do
    skip("should have feedback landmark")
  end

  scenario "should have SearchWorks navbar landmark" do
    expect(page).to have_xpath("//nav[@id='search-navbar' and @role='navigation']")
  end

  scenario "should have search form landmark" do
    expect(page).to have_xpath("//form[@role='search']")
  end

  scenario "should have context toolbar landmark" do
    skip("should have context toolbar landmark")
  end

  scenario "should have main container landmark" do
    expect(page).to have_xpath("//section[@role='main']")
  end

  scenario "should have footer landmark" do
    skip("should have footer landmark")
  end

  scenario "should have browse nearby landmark" do
    skip("should have browse nearby landmark")
  end
end
