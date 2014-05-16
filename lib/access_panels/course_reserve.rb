class CourseReserve < AccessPanel
  delegate :present?, to: :courses
  def courses
    if @document.course_reserves.present?
      @document.course_reserves.courses
    end
  end
end
