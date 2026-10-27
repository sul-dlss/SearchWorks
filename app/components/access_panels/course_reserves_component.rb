# frozen_string_literal: true

module AccessPanels
  class CourseReservesComponent < AccessPanels::Base
    def course_reserves_list
      AccessPanels::CourseReservesListComponent.new(document:)
    end

    delegate :render?, to: :course_reserves_list
  end
end
