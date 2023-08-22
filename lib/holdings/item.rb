class Holdings
  ##
  # A class representing a single barcoded item in an object's holdings.
  # This comes from the solr document's item_display field as serialized holdings info.
  # 0 barcode -|- 1 library -|- 2 home location -|- 3 current location -|- 4 item type -|-
  # 5 truncated call number -|- 6 shelfkey -|- 7 reverse shelfkey -|- 8 callnumber -|-
  # 9 full shelfkey -|- 10 public note -|- 11 callnumber type -|- 12 course id -|- 13 reserve desk -|- 14 loan period
  class Item
    MAX_SHELFKEY = 0x10FFFF.chr(Encoding::UTF_8)

    attr_writer :current_location, :status
    attr_reader :document, :item_display
    attr_accessor :due_date

    delegate :loan_type, :material_type, :effective_location, :permanent_location, to: :folio_item, allow_nil: true

    def self.from_item_display_string(item_display, document: nil)
      values = item_display.split('-|-').map(&:strip)
      hash = {
        barcode: values[0],
        library: values[1],
        home_location: values[2],
        current_location: values[3],
        type: values[4],
        lopped_callnumber: values[5],
        shelfkey: values[6],
        reverse_shelfkey: values[7],
        callnumber: values[8],
        full_shelfkey: values[9],
        note: values[10],
        scheme: values[11],
        course_id: values[12],
        reserve_desk: values[13],
        loan_period: values[14]
      }.compact_blank
      new(hash, document:)
    end

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
        (item_display[:library] == 'SUL' && (internet_resource? || eresv?)) ||
        bound_with?
    end

    def browsable?
      shelfkey.present? &&
        reverse_shelfkey.present? &&
        Constants::BROWSABLE_CALLNUMBERS.include?(callnumber_type)
    end

    def on_order?
      barcode.blank? &&
        home_location == 'ON-ORDER' &&
        current_location.code == 'ON-ORDER'
    end

    def barcode
      item_display[:barcode]
    end

    def library
      if current_location_is_reserve_desk?
        Constants::RESERVE_DESKS[current_location.code]
      else
        standard_or_zombie_library
      end
    end

    # @return [String]
    def home_location
      if treat_current_location_as_home_location?
        current_location.code
      else
        item_display[:home_location]
      end
    end

    def current_location
      @current_location ||= Holdings::Location.new(item_display[:current_location], library_code: item_display[:library])
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

    def on_reserve?
      reserve_desk.present? && loan_period.present?
    end

    def treat_current_location_as_home_location?
      Constants::CURRENT_HOME_LOCS.include?(current_location.code)
    end

    def stackmapable?
      stackmapable_library? && stackmapable_location?
    end

    def bound_with?
      Constants::BOUND_WITH_LOCS.include?(home_location)
    end

    def live_status?
      return true if folio_item?

      library != 'LANE-MED'
    end

    def circulates?
      return folio_item_circulates? if folio_item?

      circulating_item_types == '*' || circulating_item_types.include?(type)
    end

    def as_json(*)
      {
        barcode:,
        callnumber:,
        current_location: current_location.as_json,
        due_date:,
        library:,
        home_location:,
        public_note:,
        status: status.as_json,
        type:
      }
    end

    def request_link
      @request_link ||= ItemRequestLinkComponent.new(item: self)
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

    # LiveLookup::Folio uses the item UUID, while LiveLookup::Sirsi
    # uses the barcode for identifying items.
    def live_lookup_item_id
      id || folio_item&.id || barcode
    end

    def folio_item?
      folio_item.present?
    end

    def request_policy
      return unless folio_item?

      @request_policy ||= Folio::CirculationRules::PolicyService.instance.item_request_policy(self)
    end

    delegate :status, to: :folio_item, prefix: :folio

    def internet_resource?
      home_location == 'INTERNET' || type == 'ONLINE'
    end

    def eresv?
      current_location.code == 'E-RESV'
    end

    private

    # is in the list of stackmappable libraries
    def stackmapable_library?
      settings = Settings.libraries[library]
      return settings.stackmap_api.present? if settings

      Honeybadger.notify("Called stackmapable_library? on an unknown library", context: { library: })
      false
    end

    # supports a global and local skip list for home_location
    def stackmapable_location?
      return false if Settings.global_ignored_stackmap_locations.include?(home_location)

      Array(Settings.libraries[library].ignored_stackmap_locations).exclude?(home_location)
    end

    def standard_or_zombie_library
      if item_display[:library].blank? || %w(SUL PHYSICS).include?(item_display[:library])
        'ZOMBIE'
      else
        item_display[:library]
      end
    end

    def current_location_is_reserve_desk?
      Constants::RESERVE_DESKS.keys.include?(current_location.code)
    end

    def circulating_item_types
      library_map = Settings.circulating_item_types[library]

      return Settings.circulating_item_types['default'] unless library_map
      return library_map if library_map.is_a?(Array)

      library_map[home_location] || library_map['default'] || library_map
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

    def loan_policy
      @loan_policy ||= Folio::CirculationRules::PolicyService.instance.item_loan_policy(self)
    end
  end
end
