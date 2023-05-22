module AccessPanels
  class CourseReservesListComponent < AccessPanels::Base
    def initialize(document:, **html_attrs)
      super(document:)
      @html_attrs = html_attrs
    end

    def courses
      @document.course_reserves&.courses || []
    end

    def render?
      courses.any?
    end

    def link_to_course_reserve_course(course)
      link_to("#{course.id} -- #{course.name}", search_catalog_path({ f: { course: [course.id], instructor: [course.instructor] } }))
    end
  end
end
