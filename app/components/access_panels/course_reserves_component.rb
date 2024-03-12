# frozen_string_literal: true

module AccessPanels
  class CourseReservesComponent < AccessPanels::Base
    def course_reserves_list
      AccessPanels::CourseReservesListComponent.new(document:)
    end

    def render?
      course_reserves_list.render?
    end
  end
end
