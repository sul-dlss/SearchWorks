# frozen_string_literal: true

module Folio
  class Courses
    class << self
      delegate :courses, to: :instance
    end

    def self.instance
      @instance ||= new
    end

    attr_reader :folio_client

    def initialize(folio_client: FolioClient.new)
      @folio_client = folio_client
    end

    # Write courses from FOLIO to database
    def sync_courses!
      folio_courses = folio_client.courses
      # Add or update all courses retrieved from FOLIO
      folio_courses.each { |v|
        end_date = v.dig('courseListingObject', 'termObject', 'endDate')

        # Debugging https://github.com/sul-dlss/SearchWorks/issues/4631
        if end_date.blank?
          Honeybadger.notify('Course has no end date',
                             context: { id: v['id'], course_number: v['courseNumber'], name: v['name'], start_date: v.dig('courseListingObject', 'termObject', 'startDate') })
        end

        CourseReserve.where(id: v['id']).first_or_create(id: v['id']).update(
          course_number: v['courseNumber'],
          name: v['name'],
          start_date: v.dig('courseListingObject', 'termObject', 'startDate'),
          end_date:,
          is_active: Time.zone.today <= Date.parse(end_date),
          instructors: v.dig('courseListingObject', 'instructorObjects').pluck('name')
        )
      }

      # Delete courses where the course id is not returned by the current FOLIO client call
      delete_courses(folio_courses.pluck('id'), CourseReserve.pluck(:id))
    end

    # Given ids from FOLIO and current ids in the database, remove
    # whatever is in the table that is not returned by FOLIO.
    def delete_courses(folio_ids, table_ids)
      delete_ids = table_ids - folio_ids
      return if delete_ids.empty?

      CourseReserve.delete_by(id: delete_ids)
    end
  end
end
