module CourseReserveAccessPointHelper

  def create_course
    if @response.docs.first.present?
      # Get the first response doc and return it's course reserve info that matches facet params
      courses = @response.docs.first[:crez_course_info].map { |c| CourseReserves::CourseInfo.new(c)}
      @course_info = courses.find { |c| c.id == params[:f][:course][0] && c.instructor == params[:f][:instructor][0] }
    else
      # If no docs match the search params, return some course info though it will be missing course name
      @course_info = CourseReserves::CourseInfo.new("#{params[:f][:course][0]}-|--|-#{params[:f][:instructor][0]}")
    end
  end
end
