# The store of course reserve data from courses.json
class CourseReserve
  FolioCourseInfo = Data.define(:id, :course_number, :name, :instructor)

  class Repository
    include Singleton

    def all
      @all ||= Folio::Types.courses.map do |id, v|
        FolioCourseInfo.new(id:, course_number: v['courseNumber'],
                            name: v['name'],
                            instructor: v.dig('courseListingObject', 'instructorObjects').pluck('name'))
      end
    end

    def find(*ids)
      if ids.length == 1
        id = ids.first
        all.find { |course| course.id == id }
      else
        all.select { |course| ids.include?(course.id) }
      end
    end
  end

  def self.all
    Repository.instance.all
  end

  def self.find(*id)
    Repository.instance.find(*id)
  end
end
