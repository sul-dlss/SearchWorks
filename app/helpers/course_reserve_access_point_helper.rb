module CourseReserveAccessPointHelper
  require "course_reserves"

  def create_course
    courses = @response.docs.first[:crez_course_info].map { |c| CourseReserves::CourseInfo.new(c)}
    @course_info = courses.find { |c| c.id == params[:f][:course][0] && c.instructor == params[:f][:instructor][0] }
  end
end
