class Holdings
  class Location
    attr_reader :code, :items
    def initialize(code, items=[])
      @code = code
      @items = items
    end
    def name
      Constants::LOCS[@code]
    end
    def location_level_request?
      Constants::LOCATION_LEVEL_REQUEST_LOCS.include?(@code)
    end
    def one_item?
      @has_one_item ||= items.one?(&:present?)
    end
    def more_than_one_item?
      @more_than_one_item ||= items.present? && !one_item?
    end
  end
end
