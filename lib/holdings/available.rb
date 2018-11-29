class Holdings
  class Status
    class Available
      def initialize(callnumber)
        @callnumber = callnumber
      end

      def available?
        available_current_location?
      end

      private

      def available_current_location?
        Constants::FORCE_AVAILABLE_CURRENT_LOCS.include?(@callnumber.current_location.try(:code))
      end
    end
  end
end
