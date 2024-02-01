module CourseReserves
  def course_reserves
    if self.respond_to?(:[])
      @course_reserves ||= CourseReserves::Processor.new(self)
    end
  end

  def self.from_crez_info(course)
    CourseInfo.new(*course.split('-|-').map { |c| c.strip })
  end

  private

  class Processor
    def initialize(document)
      @courses = Array(document[:crez_course_info]).map { |course| CourseReserves.from_crez_info(course) }
    end

    def present?
      true ? @courses : false
    end

    attr_reader :courses
  end

  CourseInfo = Data.define(:id, :name, :instructor)
end
