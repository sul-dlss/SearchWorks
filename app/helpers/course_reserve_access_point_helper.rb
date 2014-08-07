module CourseReserveAccessPointHelper

  def create_course
    if @response.docs.present?
      # Find the document in the response that contains the requested course
      # and return it's course reserve info that matches facet params.
      @course_info = @response.docs.map do |document|
        document[:crez_course_info].map do |course|
          CourseReserves::CourseInfo.new(course)
        end.find do |course|
          course.id == params[:f][:course][0] && course.instructor == params[:f][:instructor][0]
        end
      end.compact.first
    else
      # If no docs match the search params, return some course info though it will be missing course name
      @course_info = CourseReserves::CourseInfo.new("#{params[:f][:course][0]}-|--|-#{params[:f][:instructor][0]}")
    end
  end
end
