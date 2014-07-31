class Holdings
  class Library
    include AppendMHLD
    attr_reader :code, :items
    attr_accessor :mhld
    def initialize(code, items=[])
      @code = code
      @items = items
    end
    def name
      Constants::LIB_TRANSLATIONS[@code]
    end
    def locations
      unless @locations
        @locations = @items.group_by(&:home_location).map do |location_code, items|
          Holdings::Location.new(location_code, items)
        end
        append_mhld(:location, @locations, Holdings::Location)
      end
      @locations
    end
    def holding_library?
      !zombie?
    end
    def zombie?
      @code == "ZOMBIE"
    end
    def present?
      @items.any?(&:present?) ||
      (mhld.present? && mhld.any?(&:present?))
    end
    def location_level_request?
      Constants::REQUEST_LIBS.include?(@code)
    end
  end
end
