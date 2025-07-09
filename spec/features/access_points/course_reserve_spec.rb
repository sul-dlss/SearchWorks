# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Course Reserve Access Point", :js do
  before do
    52.times { create(:course_reserve) }
    create(:course_reserve, course_number: 'MADELAST-2', name: "Alpha course", instructors: ['Condoleezza Rice'])
    visit root_path
  end

  it 'is pageable and searchable' do
    within '.features' do
      click_link "Course reserves"
    end
    expect(page).to have_title "Course reserves in SearchWorks catalog"

    within(".search-area-bg") do
      expect(page).to have_css 'h1', text: 'Course reserves'
      expect(page).to have_link "Request course reserves"
      expect(page).to have_link "More information"
    end

    expect(page).to have_content '1 - 20 of 53'
    expect(page).to have_no_content 'Alpha course'
    within '.sort-and-per-page' do
      click_link 'Next'
    end

    expect(page).to have_content '21 - 40 of 53'
    expect(page).to have_no_content 'Alpha course'

    within '.sort-and-per-page' do
      click_link 'Next'
    end
    expect(page).to have_content '41 - 53 of 53'
    expect(page).to have_content 'Alpha course'

    fill_in 'search', with: 'Knuth'
    expect(page).to have_content '1 - 20 of 52'

    fill_in 'search', with: ''
    expect(page).to have_content '1 - 20 of 53'

    click_button "Sort by Course ID"
    click_link "description"
    expect(page).to have_content 'Alpha course'
  end

  describe "visiting a result page", skip: "Still pending new design" do
    before do
      create(:reg_course)
      visit search_catalog_path({ f: { courses_folio_id_ssim: ['00254a1b-d0f5-4a9a-88a0-1dd596075d08'] } })
    end

    it "displays the Access point masthead" do
      expect(page).to have_title("Course reserves in SearchWorks catalog")
      within("#masthead") do
        expect(page).to have_css("h1", text: 'Course reserve list: ENGLISH-17Q-01')
        expect(page).to have_css("dt", text: 'Instructor')
        expect(page).to have_css("dd", text: 'Melissa Stevenson')
        expect(page).to have_css("dt", text: 'Course')
        expect(page).to have_css("dd", text: "ENGLISH-17Q-01 -- After 2001: A 21st Century Science Fiction Odyssey")
      end
      within("#content") do
        expect(page).to have_css(".document", count: 1)
      end
    end
  end
end
