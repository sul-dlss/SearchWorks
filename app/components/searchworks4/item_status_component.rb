# frozen_string_literal: true

module Searchworks4
  class ItemStatusComponent < ViewComponent::Base
    attr_reader :item, :rtac

    def initialize(item:, rtac: nil)
      @item = item
      @rtac = rtac
      super()
    end

    def dom_id
      "availability_item_#{item.live_lookup_item_id}"
    end

    def availability_icon
      return '' if availability_class == 'unknown'

      case item_status
      when 'Aged to lost', 'Claimed returned', 'Checked out', 'Awaiting delivery', 'Awaiting pickup', 'Missing', 'Long missing', 'In transit', 'Paged'
        'bi-x-lg'
      when 'In process (non-requestable)', 'In process', 'On order' # rubocop:disable Lint/DuplicateBranch
        'bi-x-lg'
      when 'Available'
        'bi-check-lg'
      else
        "bi-question"
      end
    end

    def availability_class
      if item.folio_item?
        folio_availability_class
      elsif item.on_order?
        'unavailable'
      else
        'unknown'
      end
    end

    # This display either shows a "see volumes" button in case
    # the item status is unknown or shows the status text
    def status_display
      return status_text unless availability_class == 'unknown'
      
      url = volumes_modal_path(q: @item.callnumber ||  '', search_field: 'call_number')
      "<a data-blacklight-modal='trigger' href='#{url}'>See Volumes</a>".html_safe
    end

    def status_text
      return location_provided_availability_as_status if location_provided_availability_as_status.present?

      case item_status
      when 'Aged to lost', 'Claimed returned', 'Checked out'
        'Checked out'
      when 'Awaiting delivery', 'Awaiting pickup'
        'On hold for a borrower'
      when 'In process (non-requestable)', 'In process'
        'In process'
      when 'Missing', 'Long missing'
        'Missing'
      when 'On order', 'In transit', 'Paged'
        item_status
      else
        # temp location
        return nil if item.temporary_location_text && item_status == 'Available'

        return "Available #{item.loan_period}" if item.on_reserve? && item.loan_period
        return 'Available for in-library use' if !item.circulates? && item_status == 'Available'

        item_status
      end
    end

    def temporary_location_text
      return if location_provided_availability_as_status.present?
      return unless status_text.nil? || status_text.starts_with?('Available')

      item.temporary_location_text
    end

    def folio_availability_class
      case item_status
      when 'Aged to lost', 'Claimed returned', 'Checked out', 'Awaiting delivery', 'Awaiting pickup', 'Missing', 'Long missing', 'In transit', 'Paged'
        'unavailable'
      when 'In process (non-requestable)', 'In process', 'On order' # rubocop:disable Lint/DuplicateBranch
        'unavailable'
      when 'Available'
        'available'
      else
        "unknown"
      end
    end

    def item_status
      return location_provided_availability_as_status if location_provided_availability_as_status.present?

      rtac&.dig(:status) || item.folio_status
    end

    def location_provided_availability_as_status
      case item.location_provided_availability
      when 'In_process', 'In_process_non_requestable'
        'In process'
      when 'Offsite'
        nil
      else
        item.location_provided_availability
      end
    end
  end
end
