require 'rails_helper'

RSpec.describe "catalog/_accordion_section_course_reserves" do
  describe "Accordion section - course reserves" do
    let(:document) do
      SolrDocument.new(
        id: '123',
        courses_folio_id_ssim: courses.map(&:id)
      )
    end

    let(:courses) { CourseReserve.all[0..1] }

    before do
      @document = document
      render
    end

    it "includes the course reserves accordion and text" do
      expect(rendered).to have_css('.accordion-section.course-reserves')
      expect(rendered).to have_css('.accordion-section.course-reserves button.header[aria-expanded="false"]', text: "Course reserve")
      expect(rendered).to have_css('.accordion-section.course-reserves span.snippet', text: courses.map(&:course_number).sort.join(', '))

      expect(rendered).to have_css('.accordion-section.course-reserves .details[aria-expanded="false"]')
      expect(rendered).to have_css('.accordion-section.course-reserves .details dd a', text: courses.first.name)
      expect(rendered).to have_css('.accordion-section.course-reserves .details dd a', text: courses.second.name)

      expect(rendered).to have_css('.accordion-section.course-reserves .details dt', text: "Instructor(s)")

      expect(rendered).to have_css('.accordion-section.course-reserves .details dd', text: courses.first.instructor.join)
      expect(rendered).to have_css('.accordion-section.course-reserves .details dd', text: courses.second.instructor.join)
    end
  end
end
