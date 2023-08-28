module AccessPanels
  class LocationItemComponent < ViewComponent::Base
    with_collection_parameter :item
    attr_reader :item, :document, :classes

    delegate :item_display, :internet_resource?, :eresv?, :bound_with?, to: :item

    def initialize(item:, document:, classes: nil, render_item_level_request_link: true, render_item_note: true)
      super

      @item = item
      @classes = classes
      @document = document
      @render_item_level_request_link = render_item_level_request_link
      @render_item_note = render_item_note
    end

    def availability_text
      item.status.status_text unless current_location_text
    end

    def current_location_text
      return if item.treat_current_location_as_home_location? || item.effective_location&.details&.key?('availabilityClass')

      item.current_location.name
    end

    def render_item_details?
      !item.suppressed?
    end

    def render_item_note?
      @render_item_note
    end

    def render_item_level_request_link?
      @render_item_level_request_link
    end

    def render_real_time_availability_request_link?
      # we're not rendering item-level request links (because e.g. there's already alocation level request link)
      return false unless render_item_level_request_link?

      # non-circulating items don't need real time availability
      return false unless item.circulates?

      # items that definitely have an item-level request link at render time don't need real time availability
      return false if item.request_link.render?

      true
    end

    # encourage long lines to wrap at punctuation
    # Note: the default line break character is the zero-width space
    def inject_line_break_opportunities(text, line_break_character: '​')
      text.gsub(/([:,;.]+)/, "\\1#{line_break_character}")
    end
  end
end