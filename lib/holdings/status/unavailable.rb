class Holdings
  class Status
    class Unavailable
      attr_reader :item

      delegate :library, :home_location, :current_location, to: :item

      def initialize(item)
        @item = item
      end

      def unavailable?
        unavailable_library? || unavailable_location?
      end

      private

      def unavailable_library?
        ["ZOMBIE"].include?(library)
      end

      def unavailable_location?
        unavailable_home_location? || unavailable_current_location?
      end

      def unavailable_home_location?
        Constants::UNAVAILABLE_LOCS.include?(home_location)
      end

      def unavailable_current_location?
        current_location_ends_with_loan? ||
        (Settings.unavailable_current_locations[library] || Settings.unavailable_current_locations.default).include?(current_location)
      end

      def current_location_ends_with_loan?
        current_location &&
        current_location != 'SPE-LOAN' &&
        current_location.ends_with?("-LOAN")
      end

      def current_location
        item.current_location&.code
      end
    end
  end
end
