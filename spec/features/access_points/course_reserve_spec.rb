# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Course Reserve Access Point" do
  let(:course) { CourseReserve.all.first }

  before do
    visit search_catalog_path({ f: { courses_folio_id_ssim: [course.id] } })
  end

  scenario "Access point masthead is visible with 1 course reserve document" do
    expect(page).to have_title("Course reserves in SearchWorks catalog")
    within("#masthead") do
      expect(page).to have_css("h1", text: "Course reserve list: #{course.course_number}")
      expect(page).to have_css("dt", text: "Instructor")
      expect(page).to have_css("dd", text: course.instructor.join(', '))
      expect(page).to have_css("dt", text: "Course")
      expect(page).to have_css("dd", text: "#{course.course_number} -- #{course.name.gsub(/\s+/, ' ')}")
    end
    within("#content") do
      expect(page).to have_css(".document", count: 1)
    end
  end
end
