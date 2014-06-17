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
  end
end
