require 'spec_helper'

feature 'Course reserves browse', js: true do
  scenario 'should have correct manual route' do
    visit '/reserves'
    expect(page).to have_css('h1', text: 'Browse course reserves')
  end
  scenario 'should activate the datatables plugin' do
    visit course_reserves_path
    expect(page).to have_css('#course-reserves-browse_info')
    expect(page).to have_css('#course-reserves-browse_filter')
    expect(page).to have_css('#course-reserves-browse_length')
    expect(page).to have_css('#course-reserves-browse_paginate')
  end
  scenario 'should have a link in the browse dropdown' do
    visit root_path

    within("#search-navbar .browse-dropdown") do
      click_link "Browse"

      expect(page).to have_css('li a', text: 'Course reserves', visible: true)
      click_link 'Course reserves'
    end

    expect(page).to have_css('h1', text: 'Browse course reserves')
  end
end
