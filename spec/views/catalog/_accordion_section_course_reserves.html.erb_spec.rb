# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "catalog/_accordion_section_course_reserves" do
  describe "Accordion section - course reserves" do
    let(:document) do
      SolrDocument.new(
        id: '123',
        courses_folio_id_ssim: courses.map(&:id)
      )
    end

    let(:courses) { [build(:reg_course), build(:reg_course_add)] }

    before do
      allow(CourseReserve).to receive(:find).with('00254a1b-d0f5-4a9a-88a0-1dd596075d08', '0030dde8-b82d-4585-a049-c630a93b94f2').and_return(courses)
      @document = document
      render
    end

    it "includes the course reserves accordion and text" do
      expect(rendered).to have_css('.accordion-section.course-reserves')
      expect(rendered).to have_css('.accordion-section.course-reserves button.header[aria-expanded="false"]', text: "Course reserve")
      expect(rendered).to have_css('.accordion-section.course-reserves span.snippet', text: courses.map(&:course_number).sort.join(', '))

      expect(rendered).to have_css('.accordion-section.course-reserves .details dd a', text: courses.first.name)
      expect(rendered).to have_css('.accordion-section.course-reserves .details dd a', text: courses.second.name)

      expect(rendered).to have_css('.accordion-section.course-reserves .details dt', text: "Instructor(s)")

      expect(rendered).to have_css('.accordion-section.course-reserves .details dd', text: courses.first.instructors.join)
      expect(rendered).to have_css('.accordion-section.course-reserves .details dd', text: courses.second.instructors.join)
    end
  end
end
