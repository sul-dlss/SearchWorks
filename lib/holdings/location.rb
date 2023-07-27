class Holdings
  class Location
    attr_reader :code, :items, :mhld

    # Don't send a notice to Honeybadger if we encounter one of these codes, they are expected, because they
    # didn't migrate to Folio as locations. They are item status in Folio. The ASK@LANE will not be in Folio.
    SKIP_NOTIFY_CODES = %w[INPROCESS ON-ORDER BINDERY B&F-HOLD ASK@LANE].freeze

    # @params [String] code the location code (e.g. 'STACKS')
    # @params [Array<Holdings::Item>] items ([]) a list of items at this library.
    def initialize(code, items = [], mhld = [], folio_code:)
      @code = code
      @items = items.sort_by(&:full_shelfkey)
      @mhld = mhld
      @folio_code = folio_code
    end

    def name
      return if @code.blank?

      name = Folio::Locations.label(code: @folio_code)
      return name if name

      # Fallback to legacy Folio behavior
      Honeybadger.notify("Unable to find folio location label", context: { folio_code: @folio_code, legacy_code: @code }) unless SKIP_NOTIFY_CODES.include?(@code)
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
        items: items.select(&:present?).map(&:as_json),
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
