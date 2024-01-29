module CourseReserves
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