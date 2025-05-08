# frozen_string_literal: true

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

  context 'with courses' do
    before do
      create(:reg_course)
      visit course_reserves_path
    end

    scenario 'activates the datatables plugin correctly' do
      expect(page).to have_css('#course-reserves-browse_info')
      expect(page).to have_text('Search by course ID, description, or instructor')
      expect(page).to have_css('.dt-length')
      expect(page).to have_css('.dt-paging')
      expect(page).to have_css('label', text: 'per page')
      expect(page).to have_css('li.page-item.active button', text: 1)
      expect(page).to have_css('ul.pagination li:nth-child(2)', text: 'Next')
    end
  end

  scenario 'it should have a custom masthead' do
    visit course_reserves_path
    expect(page).to have_css(".course-reserves-masthead")
    expect(page).to have_css(".inline-links a", text: "Request course reserves")
    expect(page).to have_css(".inline-links a", text: "More information")
  end
end
