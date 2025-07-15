# frozen_string_literal: true

module AccessPanels
  class LibraryLocationPopoverComponent < ViewComponent::Base
    # mhld is an array of Holdings::MHLD objects e.g. returned by location.mhld
    # This parameter will be an empty array if location has no MHLDs
    def initialize(mhld:, is_modal: false)
      @mhld = mhld
      @is_modal = is_modal
      super
    end

    def container_class
      return "d-flex justify-content-start" if @is_modal

      "d-flex justify-content-end"
    end

    def container_target
      return 'data-bs-container="#blacklight-modal"' if @is_modal

      ''
    end

    def render?
      @mhld.any? { |mhld_item| mhld_item.library_has.present? }
    end

    def popover_content
      "<div class='fw-bold mb-2'>Library has:</div><div>#{item_locations}</div>"
    end

    def item_locations
      safe_join @mhld.map(&:library_has), ', '
    end
  end
end
