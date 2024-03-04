# frozen_string_literal: true

module SearchResult
  class LocationItemComponent < ViewComponent::Base
    with_collection_parameter :item
    attr_reader :item, :document, :classes

    def initialize(item:, document:, classes: nil, render_item_level_request_link: true)
      super

      @item = item
      @classes = classes
      @document = document
      @render_item_level_request_link = render_item_level_request_link
    end

    def availability_text
      item.status.status_text unless temporary_location_text
    end

    def temporary_location_text
      return if item.effective_location&.details&.key?('availabilityClass') ||
                item.effective_location&.details&.key?('searchworksTreatTemporaryLocationAsPermanentLocation') ||
                item.effective_permanent_location_code == item.temporary_location_code

      item.temporary_location&.name
    end

    def has_in_process_availability_class?
      availability_class = item.effective_location&.details&.dig('availabilityClass')
      availability_class.present? && availability_class == 'In_process'
    end

    def render_item_details?
      !item.suppressed?
    end

    def render_item_level_request_link?
      @render_item_level_request_link
    end

    def render_real_time_availability_request_link?
      # we're not rendering item-level request links (because e.g. there's already alocation level request link)
      return false unless render_item_level_request_link?

      # don't render unless item is requestable
      return false unless item.requestable?

      # non-circulating items don't need real time availability
      return false unless item.circulates?

      # items that definitely have an item-level request link at render time don't need real time availability
      return false if item.request_link.render?

      true
    end
  end
end
