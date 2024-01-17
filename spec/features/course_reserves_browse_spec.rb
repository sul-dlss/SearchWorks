require 'rails_helper'

RSpec.feature 'Course reserves browse', :js do
  context 'homepage and subnavbar' do
    before { visit root_path }

    scenario "should be accessible from the home page" do
      within '.features' do
        click_link 'Course reserves'
      end
      expect(page).to have_css("h1", text: "Browse course reserves")
    end
    scenario "should be accessible from the subnavbar" do
      within '#search-subnavbar-container' do
        find_link('Course reserves').click
      end
      expect(page).to have_css("h1", text: "Browse course reserves")
    end
  end

  scenario 'should have correct manual route' do # TODO: move to routing spec?
    visit '/reserves'
    expect(page).to have_css('h1', text: 'Browse course reserves')
  end
  scenario 'should have search fields dropdown' do
    visit course_reserves_path
    expect(page).to have_css('select.search_field')
  end
  scenario 'should activate the datatables plugin correctly' do
    visit course_reserves_path
    expect(page).to have_css('#course-reserves-browse_info')
    expect(page).to have_css('#course-reserves-browse_filter')
    expect(page).to have_css('#course-reserves-browse_length')
    expect(page).to have_css('#course-reserves-browse_paginate')
    expect(page).to have_css('label', text: 'per page')
    expect(page).to have_css('li.paginate_button.active span', text: 1)
    expect(page).to have_css('ul.pagination li:nth-child(2)', text: 'Next')
  end
  scenario 'it should have a custom masthead' do
    visit course_reserves_path
    expect(page).to have_css(".course-reserves-masthead")
    expect(page).to have_css(".inline-links a", text: "Request course reserves")
    expect(page).to have_css(".inline-links a", text: "More information")
  end
end
