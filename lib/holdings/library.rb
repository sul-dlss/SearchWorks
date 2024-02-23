class Holdings
  class Library
    attr_reader :code, :items, :mhld

    delegate :about_url, to: :config

    # @params [String] code the library code (e.g. 'GREEN')
    # @params [Array<Holdings::Item>] items ([]) a list of items at this library.
    def initialize(code, items = [], mhld = [])
      @code = code
      @items = items
      @mhld = mhld
    end

    def name
      return config.name unless items.any?(&:folio_item?)

      @name ||= begin
        folio_item = items.first(&:folio_item)

        # use the effective location's library name if we're treating it as the permanent location;
        # by the time we get here, we're already grouped by the item's library code which respects
        # the same rules
        name = folio_item.effective_location&.library&.name if folio_item.effective_location&.details&.dig('searchworksTreatTemporaryLocationAsPermanentLocation')
        # prefer the name from the cached folio data (for consistency across records)
        name ||= folio_item.permanent_location&.library&.name
        # fall back on the name from the document
        name || config.name
      end
    end

    # @return [Array<Holdings::Location>] the locations with the holdings
    def locations
      unless @locations
        @locations = @items.group_by do |item|
          # Group by display labels if they are the same. (e.g. both MSS-30 (SPEC-SAL3-MSS) and MANUSCRIPT (SPEC-MANUSCRIPT) translate to "Manuscript Collection")
          Folio::Locations.label(code: item.effective_permanent_location_code) || item.effective_permanent_location_code
        end.map do |_, items|
          location_code = items.first.effective_permanent_location_code
          mhlds = mhld.select { |x| x.location == location_code }
          Holdings::Location.new(location_code, items, mhlds)
        end

        @locations += mhld.reject { |x| @locations.map(&:code).include? x.location }.group_by(&:location).map do |location_code, mhlds|
          Holdings::Location.new(location_code, [], mhlds)
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
      @items.reject(&:suppressed?).any? ||
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

    def config
      Settings.libraries[@code] || Settings.libraries.default
    end
  end
end
