require "spec_helper"

describe "catalog/_accordion_section_course_reserves.html.erb" do

  describe "Accordion section - course reserves" do

    before do
      assign(:document,
        SolrDocument.new(
          id: '123',
          crez_course_info: [
            "ACCT-212-01-02 -|- Managerial Accounting: Base -|- Reichelstein, Stefan J",
            "ACCT-215-01-02 -|- Managerial Accounting: Accelerated -|- Marinovic Vial, Ivan"
          ]
        )
      )
      render
    end

    it "should include the course reserves accordion and text" do
      expect(rendered).to have_css('.accordion-section.course-reserves')
      expect(rendered).to have_css('.accordion-section.course-reserves a.header', text: "Course Reserves (2)")
      expect(rendered).to have_css('.accordion-section.course-reserves span.snippet', text: "ACCT-212-01-02, ACCT-215-01-02")

      expect(rendered).to have_css('.accordion-section.course-reserves .details dt a', text: "Managerial Accounting: Base")
      expect(rendered).to have_css('.accordion-section.course-reserves .details dt a', text: "Managerial Accounting: Accelerated")

      expect(rendered).to have_css('.accordion-section.course-reserves .details dd .course-reserve-title', text: "INSTRUCTOR(S):")

      expect(rendered).to have_css('.accordion-section.course-reserves .details dd .text-muted', text: "Reichelstein, Stefan J")
      expect(rendered).to have_css('.accordion-section.course-reserves .details dd .text-muted', text: "Marinovic Vial, Ivan")
    end
  end

end
