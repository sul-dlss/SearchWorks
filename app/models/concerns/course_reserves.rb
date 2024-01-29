module CourseReserves
  def course_reserves
    if self.respond_to?(:[])
      @course_reserves ||= CourseReserves::Processor.new(self)
    end
  end

  private

  class Processor
    def initialize(document)
      @courses = document[:crez_course_info].map { |course| CourseInfo.new(course) } unless document[:crez_course_info].nil?
    end

    def present?
      true ? @courses : false
    end

    attr_reader :courses
  end
end
