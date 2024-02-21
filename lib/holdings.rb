class Holdings
  attr_reader :items, :mhld, :folio_holdings, :folio_items

  # @params [Array<Holdings::Item>] items ([]) a list of items.
  # @params [Array<Holdings::MHLD>] mhld ([]) a list of mhld.
  # @params [Array<Folio::Holding>] folio_holdings ([]) a list of holdings from Folio.
  # @params [Array<Folio::Item>] folio_items ([]) a list of items from Folio.
  def initialize(items = [], mhld = [], folio_holdings = [], folio_items = []) # rubocop:disable Metrics/ParameterLists
    @items = items
    @mhld = mhld
    @folio_holdings = folio_holdings
    @folio_items = folio_items
  end

  def present?
    libraries.select(&:present?).any? do |library|
      library.locations.any?(&:present?)
    end
  end

  def browsable_items
    items.select(&:browsable?).uniq(&:truncated_callnumber)
  end

  # @return [Array<Holdings::Library>] the list of libraries with holdings
  def libraries
    unless @libraries
      items_by_library = items.group_by(&:library)

      @libraries = items_by_library.map do |library_code, items|
        mhlds = mhld.select { |x| x.library == library_code }
        selected_holdings = folio_holdings.select { |folio_holding| folio_holding.effective_location.library.code == library_code }
        selected_items = folio_items.select { |folio_item| folio_item.effective_location.library.code == library_code }
        Holdings::Library.new(library_code, items, mhlds, selected_holdings, selected_items)
      end

      # Find the MHLDs that are for a library that has no items.
      @libraries += mhld.reject { |x| items_by_library.key? x.library }.group_by(&:library).map do |code, mhlds|
        Holdings::Library.new(code, [], mhlds)
      end

      @libraries.sort_by!(&:sort)
    end
    @libraries
  end

  def find_by_barcode(barcode)
    items.find { |item| item.barcode == barcode }
  end

  def as_json
    libraries.select(&:present?).map(&:as_json)
  end
end
