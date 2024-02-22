class Holdings
  attr_reader :items, :mhld

  # @params [Array<Holdings::Item>] items ([]) a list of items.
  # @params [Array<Holdings::MHLD>] mhld ([]) a list of mhld.
  def initialize(items = [], mhld = [])
    @items = items
    @mhld = mhld
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

      @libraries = items_by_library.map do |library, items|
        mhlds = mhld.select { |x| x.library == library }
        Holdings::Library.new(library, items, mhlds)
      end

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
end
