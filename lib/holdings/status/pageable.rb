class Holdings
  class Status
    class Pageable
      def initialize(callnumber)
        @callnumber = callnumber
      end

      def pageable?
        pageable_home_location? || pageable_library?
      end

      private

      def pageable_library?
        ["SAL3", "SAL-NEWARK"].include?(@callnumber.library)
      end

      def pageable_home_location?
        @callnumber.home_location.try(:end_with?, '-30') ||
        Constants::PAGE_LOCS.include?(@callnumber.home_location)
      end
    end
  end
end
