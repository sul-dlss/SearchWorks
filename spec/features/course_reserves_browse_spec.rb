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
end
