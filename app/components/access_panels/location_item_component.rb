# frozen_string_literal: true

module AccessPanels
  class LocationItemComponent < ViewComponent::Base
    with_collection_parameter :item
    attr_reader :item, :document, :classes

    def initialize(item:, document:, item_counter: nil, classes: nil, consolidate_for_finding_aid: false, modal: false)
      super

      @item = item
      @classes = classes
      @document = document
      @consolidate_for_finding_aid = consolidate_for_finding_aid
      @item_counter = item_counter
      @modal = modal
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
      return false if consolidate_for_finding_aid? && @item_counter.positive?

      true
    end

    def consolidate_for_finding_aid?
      @consolidate_for_finding_aid
    end

    # encourage long lines to wrap at punctuation
    # Note: the default line break character is the zero-width space
    def inject_line_break_opportunities(text, line_break_character: '​')
      text.gsub(/([:,;.]+)/, "\\1#{line_break_character}")
    end
  end
end
