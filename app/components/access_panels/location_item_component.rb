# frozen_string_literal: true

module AccessPanels
  class LocationItemComponent < ViewComponent::Base
    with_collection_parameter :item
    attr_reader :item, :document, :classes, :counter

    def initialize(item:, document:, item_counter:, item_iteration:, classes: nil, render_item_note: true, render_item_level_request_link: true, consolidate_for_finding_aid: false)
      super

      @item = item
      @classes = classes
      @document = document
      @render_item_note = render_item_note
      @render_item_level_request_link = render_item_level_request_link
      @consolidate_for_finding_aid = consolidate_for_finding_aid
      @counter = item_counter
      @iteration = item_iteration
    end

    delegate :bound_with_parent, to: :item

    def callnumber
      return item.truncated_callnumber if consolidate_for_finding_aid?

      item.callnumber
    end

    def has_bound_with_parent?
      bound_with_parent.present?
    end

    def bound_with_title
      bound_with_parent['title']
    end

    def bound_with_callnumber
      [bound_with_parent['call_number'], bound_with_parent['volume'], bound_with_parent['enumeration'], bound_with_parent['chronology']].compact.join(' ')
    end

    delegate :has_in_process_availability_class?, :temporary_location_text, :availability_text, to: :item

    def render?
      return false if consolidate_for_finding_aid? && !@iteration.first?

      true
    end

    def availability_class
      state = item.status.availability_class

      case state
      when 'available', 'noncirc'
        "#{state} bi-check-lg"
      when 'deliver-from-offsite', 'noncirc_page'
        "#{state} bi-truck"
      when 'unavailable', 'in_process'
        "#{state} bi-x"
      else
        "#{state} bi-question"
      end
    end

    def consolidate_for_finding_aid?
      @consolidate_for_finding_aid
    end

    def render_item_note?
      @render_item_note
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

    # encourage long lines to wrap at punctuation
    # Note: the default line break character is the zero-width space
    def inject_line_break_opportunities(text, line_break_character: '​')
      text.gsub(/([:,;.]+)/, "\\1#{line_break_character}")
    end
  end
end
