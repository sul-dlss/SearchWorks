class Holdings
  class Status
    class NoncircPage
      LIBRARIES = ['HV-ARCHIVE', 'RUMSEYMAP', 'SPEC-COLL'].freeze

      def initialize(callnumber)
        @callnumber = callnumber
      end

      def noncirc_page?
        library_noncirc_page? || location_noncirc_page?
      end

      private

      def location_noncirc_page?
        home_location_noncirc_page? || current_location_noncirc_page?
      end

      def home_location_noncirc_page?
        Constants::NONCIRC_PAGE_LOCS.include?(@callnumber.home_location)
      end

      def current_location_noncirc_page?
        Constants::FORCE_NONCIRC_CURRENT_LOCS.include?(@callnumber.current_location.try(:code))
      end

      def library_noncirc_page?
        LIBRARIES.include?(@callnumber.library)
      end
    end
  end
end
