# encoding: utf-8
require "spec_helper"

describe "Special Quotes", type: :feature do
  it "should replace special quotes in the query" do
    visit root_path
    fill_in 'q', with: '『stuff』'
    click_button 'search'

    within('.breadcrumb') do
      expect(page).to have_content '"stuff"'
      expect(page).to_not have_content '『stuff』'
    end
  end
end
