class CourseReserve < AccessPanel
  delegate :present?, to: :courses
  def courses
    if @document.course_reserves.present?
      @document.course_reserves.courses
    end
  end


  # def initialize(course)
  #   # super
  #   @course = course.split('-|-').map{ |i| i.strip }
  #   @id = @course[0]
  #   @course_name = @course[1]
  #   @instructor = @coursep[2]
  # end

  # attr_reader :id, :course_name, :instructor

end
