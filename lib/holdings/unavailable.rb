class Holdings
  class Status
    class Unavailable
      def initialize(callnumber)
        @callnumber = callnumber
      end

      def unavailable?
        unavailable_library? || unavailable_location?
      end

      private

      def unavailable_library?
        ["ZOMBIE"].include?(@callnumber.library)
      end

      def unavailable_location?
        unavailable_home_location? || unavailable_current_location?
      end

      def unavailable_home_location?
        Constants::UNAVAILABLE_LOCS.include?(@callnumber.home_location)
      end

      def unavailable_current_location?
        current_location_ends_with_loan? ||
        Constants::UNAVAILABLE_CURRENT_LOCS.include?(@callnumber.current_location.try(:code))
      end

      def current_location_ends_with_loan?
        @callnumber.current_location.try(:code) &&
        @callnumber.current_location.code != 'SPE-LOAN' &&
        @callnumber.current_location.code.ends_with?("-LOAN")
      end
    end
  end
end
