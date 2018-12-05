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

  class CourseInfo
    def initialize(course)
      @course = course.split('-|-').map { |c| c.strip }
    end

    def id
      @course[0]
    end

    def name
      @course[1]
    end

    def instructor
      @course[2]
    end
  end
end
