# frozen_string_literal: true

module AccessPanels
  class CourseReservesListComponent < AccessPanels::Base
    def initialize(document:, **html_attrs)
      super(document:)
      @html_attrs = html_attrs
    end

    def courses
      @document.course_reserves
    end

    def render?
      courses.any?
    end

    def link_to_course_reserve_course(course)
      link_to("#{course.course_number} -- #{course.name}", search_catalog_path({ f: { courses_folio_id_ssim: [course.id] } }))
    end
  end
end
