
# frozen_string_literal: true

module AccessPanels
    class LibraryLocationPopoverComponent < ViewComponent::Base
      
        # location.mhld
      def initialize(mhld, left:false)
        @mhld = mhld
      end

      def render?
        @mhld.present? && @mhld.any? { |mhld_item| mhld_item.library_has.present? }
      end

      def popover_content
        sanitize "<div class='fw-bold mb-2'>Library has:</div><div> #{item_locations}</div>"
      end


      def item_locations
        @mhld.map do |mhld_item|
            library_has(mhld_item)
        end.join(', ')   
      end

      def library_has(mhld_item)
        return "" if mhld_item.library_has.blank?

        mhld_item.library_has
      end
    end
end

