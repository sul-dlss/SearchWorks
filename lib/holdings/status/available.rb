class Holdings
  class Status
    class Available
      def initialize(item)
        @item = item
      end

      def available?
        available_current_location?
      end

      private

      def available_current_location?
        Constants::FORCE_AVAILABLE_CURRENT_LOCS.include?(@item.current_location.try(:code))
      end
    end
  end
end
