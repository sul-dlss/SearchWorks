class Holdings
  class Status
    class Unknown
      def initialize(callnumber)
        @callnumber = callnumber
      end

      def unknown?
        unknown_library? || unknown_location?
      end

      private

      def unknown_library?
        ["LANE-MED"].include?(@callnumber.library)
      end

      def unknown_location?
        Constants::UNKNOWN_LOCS.include?(@callnumber.home_location)
      end
    end
  end
end
