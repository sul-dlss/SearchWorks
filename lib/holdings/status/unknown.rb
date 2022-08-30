class Holdings
  class Status
    class Unknown
      def initialize(item)
        @item = item
      end

      def unknown?
        unknown_library? || unknown_location?
      end

      private

      def unknown_library?
        ["LANE-MED"].include?(@item.library)
      end

      def unknown_location?
        Constants::UNKNOWN_LOCS.include?(@item.home_location)
      end
    end
  end
end
