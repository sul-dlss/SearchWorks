class Holdings
  class Status
    class Noncirc
      def initialize(callnumber)
        @callnumber = callnumber
        @noncirc = determine_noncirc_status
      end

      def noncirc?
        @noncirc
      end

      private

      def business_noncirc_locations
        Constants::NONCIRC_LOCS.concat(["NEWS-STKS", "MICROFILM"]).include?(@callnumber.home_location)
      end

      def ars_noncirc_types
        @callnumber.type != "STKS" || type_is_default_noncirc?
      end

      def determine_noncirc_status
        location_is_noncirc? || type_is_noncirc?
      end

      def location_is_noncirc?
        send("#{sanitized_library}_noncirc_locations")
      end

      def type_is_noncirc?
        send("#{sanitized_library}_noncirc_types")
      end

      def location_is_default_noncirc?
        Constants::NONCIRC_LOCS.include?(@callnumber.home_location)
      end

      def type_is_default_noncirc?
        ["REF", "NONCIRC", "LIBUSEONLY"].include?(@callnumber.type)
      end

      def sanitized_library
        @callnumber.library.downcase.gsub('-', '_') if @callnumber.library.present?
      end

      def method_missing(method_name, *args, &block)
        case method_name
        when /_noncirc_locations$/
          location_is_default_noncirc?
        when /_noncirc_types$/
          type_is_default_noncirc?
        else
          super
        end
      end
    end
  end
end
