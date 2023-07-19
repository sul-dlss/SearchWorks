class Holdings
  class Status
    class DeliverFromOffsite
      def initialize(item)
        @item = item
      end

      def deliver_from_offsite?
        deliverable_home_location? || offsite_library?
      end

      private

      def offsite_library?
        ["SAL3", "SAL-NEWARK"].include?(@item.library)
      end

      def deliverable_home_location?
        @item.home_location.try(:end_with?, '-30') ||
          Constants::DELIVERABLE_LOCATIONS.include?(@item.home_location)
      end
    end
  end
end
