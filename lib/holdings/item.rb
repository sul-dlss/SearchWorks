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
      @item_display.values.none?(&:present?) ||
        (item_display[:library] == 'SUL' && internet_resource?)
    end

    def browsable?
      shelfkey.present? &&
        reverse_shelfkey.present? &&
        Constants::BROWSABLE_CALLNUMBERS.include?(callnumber_type)
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

    # @return [String]
    def home_location
      item_display[:home_location]
    end

    def temporary_location_code
      item_display[:temporary_location_code]
    end

    def temporary_location
      @temporary_location ||= Holdings::Location.new(item_display[:temporary_location_code])
    end

    def type
      item_display[:type]
    end

    def truncated_callnumber
      item_display[:lopped_callnumber]
    end

    def shelfkey
      item_display[:shelfkey]
    end

    def reverse_shelfkey
      item_display[:reverse_shelfkey]
    end

    def callnumber
      case
      when item_display[:callnumber].present?
        item_display[:callnumber]
      when internet_resource?
        'eResource'
      else
        '(no call number)'
      end
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
      return nil unless document&.folio_holdings&.any?

      match = document.folio_holdings.find do |holding|
        holding.bound_with_parent&.dig('item', 'id') == id
      end
      match&.bound_with_parent
    end

    def bound_with?
      bound_with_parent.present?
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

    # create sorting key for spine
    # shelfkey asc, then by sorting title asc, then by pub date desc
    # note: pub_date must be inverted for descending sort
    def spine_sort_key
      sort_pub_date = if document[:pub_date].blank?
                        '9999'
                      else
                        document[:pub_date].tr('0123456789', '9876543210')
                      end

      [
        shelfkey,
        document[:title_sort].to_s,
        sort_pub_date,
        document[:id].to_s
      ]
    end

    # LiveLookup::Folio uses the item UUID
    def live_lookup_item_id
      id || folio_item&.id
    end

    def live_lookup_instance_id
      bound_with? ? bound_with_parent.dig('instance', 'id') : document.live_lookup_id
    end

    def folio_item?
      folio_item.present?
    end

    def allowed_request_types
      request_policy&.dig('requestTypes') || []
    end

    def internet_resource?
      type == 'ONLINE'
    end

    private

    def standard_or_zombie_library
      item_display[:library].presence || 'ZOMBIE'
    end

    def folio_item
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

    def folio_item_circulates?
      loan_policy&.dig('loanable')
    end

    def request_policy
      return unless folio_item?

      @request_policy ||= Folio::CirculationRules::PolicyService.instance.item_request_policy(self)
    end

    def loan_policy
      @loan_policy ||= Folio::CirculationRules::PolicyService.instance.item_loan_policy(self)
    end
  end
end
