# encoding: utf-8

require 'rails_helper'

RSpec.describe "Special Quotes" do
  it "should replace special quotes in the query" do
    visit root_path
    fill_in 'q', with: '『stuff』'
    click_button 'search'

    within('.breadcrumb') do
      expect(page).to have_content '"stuff"'
      expect(page).not_to have_content '『stuff』'
    end
  end
end
