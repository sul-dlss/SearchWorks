class Holdings
  class Location
    attr_reader :code, :items, :mhld

    # @params [String] code the location code (e.g. 'STACKS')
    # @params [Array<Holdings::Item>] items ([]) a list of items at this library.
    def initialize(code, items = [], mhld = [], library_code: nil)
      @code = code
      @items = items.sort_by(&:full_shelfkey)
      @mhld = mhld
      @library_code = library_code
    end

    def name
      return if @code.blank?

      # Prefer location names as managed in FOLIO
      name = Folio::Locations.label(code: folio_code)
      return name if name

      # Fallback to legacy behavior
      Constants::LOCS.fetch(@code, @code)
    end

    def bound_with?
      @code && Constants::BOUND_WITH_LOCS.include?(@code)
    end

    def location_link
      return unless library == 'LANE-MED'
      return if items.any?(&:folio_item?)

      if items.first.try(:barcode)
        "https://lane.stanford.edu/view/bib/#{items.first.barcode.gsub(/^LL/, '')}"
      else
        'https://lane.stanford.edu'
      end
    end

    def present?
      any_items? || any_mhlds? || bound_with?
    end

    def present_on_index?
      any_items? || any_index_mhlds? || @code == 'SEE-OTHER'
    end

    def sort
      name || @code
    end

    def as_json
      {
        code:,
        items: items.reject(&:suppressed?).map(&:as_json),
        mhld: mhld&.select(&:present?)&.map(&:as_json),
        name:
      }
    end

    private

    def library
      if any_items?
        items.first.library
      elsif any_mhlds?
        mhld.first.library
      end
    end

    def sanitized_library
      library.downcase.gsub('-', '_') if library
    end

    def any_items?
      items.reject(&:suppressed?).any?
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

    def folio_code
      @folio_code ||= Folio::LocationsMap.for(library_code: @library_code, location_code: code)
    end
  end
end
