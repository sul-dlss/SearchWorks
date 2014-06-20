class Holdings
  class Library
    attr_reader :code, :items
    def initialize(code, items=[])
      @code = code
      @items = items
    end
    def name
      Constants::LIB_TRANSLATIONS[@code]
    end
    def locations
      @locations ||= @items.group_by(&:home_location).map do |location_code, items|
        Holdings::Location.new(location_code, items)
      end
    end
    def is_viewable?
      @code.present? && !["SUL", "PHYSICS"].include?(@code)
    end
    def location_level_request?
      Constants::REQUEST_LIBS.include?(@code)
    end
  end
end
