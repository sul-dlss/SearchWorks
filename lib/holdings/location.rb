class Holdings
  class Location
    attr_reader :code, :items
    attr_accessor :mhld
    def initialize(code, items=[])
      @code = code
      @items = items.sort_by(&:full_shelfkey)
    end
    def name
      Constants::LOCS[@code]
    end
    def bound_with?
      @code && @code == "SEE-OTHER"
    end
    def location_level_request?
      Constants::LOCATION_LEVEL_REQUEST_LOCS.include?(@code)
    end
    def present?
      any_items? || any_mhlds?
    end
    def present_on_index?
      any_items? || any_index_mhlds?
    end
    def sort
      name || @code
    end
    private
    def any_items?
      items.any?(&:present?)
    end
    def any_mhlds?
      mhld.present? && mhld.any?(&:present?)
    end
    def any_index_mhlds?
      mhld.present? && mhld.any? do |mhld_item|
        mhld_item.latest_received.present? ||
        mhld_item.public_note.present?
      end
    end
  end
end
