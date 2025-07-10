
# frozen_string_literal: true

module AccessPanels
    class LibraryLocationPopoverComponent < ViewComponent::Base
      
        # location.mhld
      def initialize(mhld)
        @mhld = mhld
      end

      def render?
        mhld.library_has.present?
      end

      def popover_content
        sanitize "<div class='fw-bold mb-2'>Library has:</div><div> #{item_locations}</div>"
      end


      def item_locations
        @mhld.map do |mhld|
            library_has(mhld)
        end.join(', ')   
      end

      def library_has(mhld)
        return "" if mhld.library_has.blank?

        mhld.library_has
      end
    end
end

