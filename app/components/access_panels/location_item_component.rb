# frozen_string_literal: true

module AccessPanels
  class LocationItemComponent < ViewComponent::Base
    with_collection_parameter :item
    attr_reader :item, :document, :classes

    def initialize(item:, document:, item_counter: nil, classes: 'item-row pt-1 w-100 flex-wrap border-top fs-15', consolidate_for_finding_aid: false)
      super()

      @item = item
      @classes = classes
      @document = document
      @consolidate_for_finding_aid = consolidate_for_finding_aid
      @item_counter = item_counter
    end

    def callnumber
      return item.truncated_callnumber if consolidate_for_finding_aid?

      item.callnumber
    end

    delegate :has_in_process_availability_class?, :temporary_location_text, :availability_text, to: :item

    def render?
      return false if consolidate_for_finding_aid? && @item_counter.positive?

      true
    end

    def consolidate_for_finding_aid?
      @consolidate_for_finding_aid
    end

    def note?
      note_component.render?
    end

    def boundwith?
      boundwith_parent_component.render? || boundwith_principal_component.render?
    end

    def note_component
      @note_component ||= Searchworks4::Item::PublicNoteComponent.new(item:)
    end

    def boundwith_parent_component
      @boundwith_parent_component ||= Searchworks4::Item::BoundWithParentComponent.new(item:, document:)
    end

    def boundwith_principal_component
      @boundwith_principal_component ||= Searchworks4::Item::BoundWithPrincipalComponent.new(item:, document:)
    end
  end
end
