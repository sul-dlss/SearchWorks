class Holdings
  class Location
    attr_reader :code, :items, :mhld, :folio_holdings, :folio_items

    # @params [String] code the location code (e.g. 'GRE-STACKS')
    # @params [Array<Holdings::Item>] items ([]) a list of items at this library.
    # @params [Array<Folio::Holding>] folio_holdings ([]) a list of holdings from Folio.
    # @params [Array<Folio::Item>] folio_items ([]) a list of items from Folio.
    def initialize(code, items = [], mhld = [], folio_holdings = [], folio_items = []) # rubocop:disable Metrics/ParameterLists
      @code = code
      @items = items.sort_by(&:full_shelfkey)
      @mhld = mhld
      @folio_holdings = folio_holdings
      @folio_items = folio_items
    end

    def name
      return if @code.blank?

      Folio::Locations.label(code: @code)
    end

    def stackmapable?
      stackmap_api_url.present?
    end

    def stackmap_api_url
      Folio::Locations.stackmap_api_url(code: @code)
    end

    def bound_with?
      items.any?(&:bound_with?)
    end

    # Intentionally left blank
    def location_link; end

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

    def any_items?
      items.reject(&:suppressed?).any?
    end

    def any_mhlds?
      mhld.any?(&:present?)
    end

    def any_index_mhlds?
      mhld.any? do |mhld_item|
        mhld_item.latest_received.present? ||
          mhld_item.public_note.present?
      end
    end
  end
end
