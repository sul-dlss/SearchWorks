class Holdings
  class Library
    attr_reader :code, :items, :mhld

    delegate :name, :about_url, to: :config

    # @params [String] code the library code (e.g. 'GREEN')
    # @params [Array<Holdings::Item>] items ([]) a list of items at this library.
    def initialize(code, items = [], mhld = [])
      @code = code
      @items = items
      @mhld = mhld
    end

    # @return [Array<Holdings::Location>] the locations with the holdings
    def locations
      unless @locations
        @locations = @items.group_by do |item|
          # Group by display labels if they are the same. (e.g. both MSS-30 (SPEC-SAL3-MSS) and MANUSCRIPT (SPEC-MANUSCRIPT) translate to "Manuscript Collection")
          folio_code = Folio::LocationsMap.for(library_code: code, location_code: item.home_location)
          Folio::Locations.label(code: folio_code) || folio_code || item.home_location
        end.map do |_, items|
          location_code = items.first.home_location
          mhlds = mhld.select { |x| x.location == location_code }
          Holdings::Location.new(location_code, items, mhlds,
                                 folio_code: Folio::LocationsMap.for(library_code: code, location_code:))
        end

        @locations += mhld.reject { |x| @locations.map(&:code).include? x.location }.group_by(&:location).map do |location_code, mhlds|
          Holdings::Location.new(location_code, [], mhlds,
                                 folio_code: Folio::LocationsMap.for(library_code: code, location_code:))
        end

        @locations.sort_by!(&:sort)
      end
      @locations
    end

    def holding_library?
      !zombie?
    end

    def zombie?
      @code == 'ZOMBIE'
    end

    def present?
      @items.any?(&:present?) ||
        (mhld.present? && mhld.any?(&:present?)) ||
        locations.any?(&:bound_with?)
    end

    def library_instructions
      Constants::LIBRARY_INSTRUCTIONS[@code]
    end

    def sort
      if @code == 'GREEN'
        '0'
      else
        name || @code
      end
    end

    def as_json
      {
        code:,
        locations: locations.select(&:present?).map(&:as_json),
        mhld: mhld.select(&:present?).map(&:as_json),
        name:,
        library_instructions:
      }
    end

    def config
      Settings.libraries[@code] || Settings.libraries.default
    end
  end
end
