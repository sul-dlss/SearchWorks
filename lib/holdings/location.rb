class Holdings
  class Location
    attr_reader :code, :items
    attr_accessor :mhld
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
  end
end
