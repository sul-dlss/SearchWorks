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

    def popover_title
      '<div class="d-flex justify-content-between align-content-center">
        <div class="fw-bold align-self-center">Library has:</div>
        <button class="btn p-0 ms-2 fs-5 lh-1" aria-label="close summary of items popover" data-action="click->popover#hidePopover" type="button">
          <i class="bi bi-x"></i>
        </button>
      </div>'
    end

    def item_locations
      safe_join @mhld.map(&:library_has), ', '
    end
  end
end
