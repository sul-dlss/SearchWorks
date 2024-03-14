# frozen_string_literal: true

module CourseReserves
  def course_reserves
    @course_reserves ||= course_ids.present? ? Array(CourseReserve.find(*course_ids)).sort_by(&:course_number) : []
  end
end
