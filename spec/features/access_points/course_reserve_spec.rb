# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Course Reserve Access Point" do
  before do
    create(:reg_course)
    visit search_catalog_path({ f: { courses_folio_id_ssim: ['00254a1b-d0f5-4a9a-88a0-1dd596075d08'] } })
  end

  scenario "Access point masthead is visible with 1 course reserve document", skip: "working on post database transfer of courses" do
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
