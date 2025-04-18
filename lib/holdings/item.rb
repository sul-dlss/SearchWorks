# frozen_string_literal: true

class Holdings
  ##
  # A class representing a single barcoded item in an object's holdings.
  class Item
    MAX_SHELFKEY = 0x10FFFF.chr(Encoding::UTF_8)

    attr_writer :status
    attr_reader :document, :item_display
    attr_accessor :due_date

    delegate :loan_type, :material_type, :effective_location, :location_provided_availability, :permanent_location,
             to: :folio_item, allow_nil: true

    # @param [Hash] holding_info this is one row of data from item_display_struct
    # @param [SolrDocument] document
    # @param [Folio::Item] folio_item may be nil if the item is a bound-with child.
    def initialize(holding_info, document: nil, folio_item: nil)
      @item_display = holding_info.with_indifferent_access
      @document = document
      @folio_item = folio_item
    end

    def id
      @item_display[:id]
    end

    def suppressed?
      @item_display.values.none?(&:present?)
    end

    def on_order?
      folio_status == 'On order'
    end

    def barcode
      item_display[:barcode]
    end

    def library
      standard_or_zombie_library
    end

    # This is generally the item's permanent location, but it can also be
    # the temporary location if the location detail searchworksTreatTemporaryLocationAsPermanentLocation
    # is set to true.
    def effective_permanent_location_code
      item_display[:effective_permanent_location_code]
    end

    # NOTE: This may be nil
    def temporary_location_code
      item_display[:temporary_location_code]
    end

    def temporary_location
      @temporary_location ||= Holdings::Location.new(temporary_location_code) if temporary_location_code
    end

    def type
      item_display[:type]
    end

    def bound_with_id
      bound_with_parent[:hrid]&.sub(/^a(\d+)$/, '\1')
    end

    def truncated_callnumber
      item_display[:lopped_callnumber]
    end

    def callnumber
      item_display[:callnumber].presence || '(no call number)'
    end

    def full_shelfkey(default: MAX_SHELFKEY)
      item_display[:full_shelfkey] || default
    end

    def public_note
      item_display[:note]&.gsub('.PUBLIC.', '')&.strip
    end

    def callnumber_type
      item_display[:scheme]
    end

    def course_id
      item_display[:course_id]
    end

    def reserve_desk
      item_display[:reserve_desk]
    end

    def loan_period
      item_display[:loan_period]
    end

    def status
      @status ||= Holdings::Status.new(self)
    end

    def folio_status
      item_display[:status]
    end

    def on_reserve?
      course_id.present?
    end

    def bound_with_parent
      item_display[:bound_with]
    end

    # @return [Bool] true if this is a bound-with
    def bound_with?
      bound_with_child? || bound_with_principal?
    end

    # @return [Bool] true if this is a bound-with child
    def bound_with_child?
      bound_with_parent.present?
    end

    def bound_with_principal?
      item_display[:is_bound_with_principal]
    end

    def circulates?
      folio_item? && folio_item_circulates?
    end

    def request_link
      @request_link ||= ItemRequestLinkComponent.new(item: self)
    end

    # Check to see if the item is ever eligible for hold/recall. Used to determine whether a request link could be added by live lookup.
    def requestable?
      @requestable ||= ItemRequestLinkPolicy.new(item: self).item_allows_hold_recall?
    end

    # LiveLookup::Folio uses the item UUID
    def live_lookup_item_id
      id || folio_item&.id
    end

    def folio_item?
      folio_item.present?
    end

    def allowed_request_types
      request_policy&.dig('requestTypes') || []
    end

    def availability_text
      status.status_text unless temporary_location_text
    end

    def temporary_location_text
      return if effective_location&.details&.key?('availabilityClass') ||
                effective_location&.details&.key?('searchworksTreatTemporaryLocationAsPermanentLocation') ||
                effective_permanent_location_code == temporary_location_code

      temporary_location&.name
    end

    def has_in_process_availability_class?
      availability_class = effective_location&.details&.dig('availabilityClass')
      availability_class.present? && availability_class == 'In_process'
    end

    private

    def standard_or_zombie_library
      item_display[:library].presence || 'ZOMBIE'
    end

    def folio_item
      return bound_with_folio_item if bound_with_child?

      @folio_item ||= document&.folio_items&.find do |item|
        # We prefer to match on the item id (uuid) because the barcode
        # might be missing or duplicated.
        if id.present?
          item.id == id
        else
          item.barcode == barcode
        end
      end
    end

    def bound_with_folio_item
      @bound_with_folio_item ||= document&.bound_with_folio_items&.find do |item|
        item.id == id
      end
    end

    def folio_item_circulates?
      loan_policy&.dig('loanable')
    end

    def request_policy
      return unless folio_item? && material_type.present? && loan_type.present?

      @request_policy ||= Folio::CirculationRules::PolicyService.instance.item_request_policy(self)
    end

    def loan_policy
      return unless folio_item? && material_type.present? && loan_type.present?

      @loan_policy ||= Folio::CirculationRules::PolicyService.instance.item_loan_policy(self)
    end
  end
end
