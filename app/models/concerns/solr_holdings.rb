module SolrHoldings
  def holdings
    @holdings ||= Holdings.new(items, mhld)
  end

  def mhld
    return [] if self[:mhld_display].blank?

    @mhld ||= self[:mhld_display].map do |mhld_display|
      Holdings::MHLD.new(mhld_display)
    end
  end

  # item_display_struct contains fake items for eresources and boundwiths, which is why we don't use holdings_json_struct directly
  def items
    return [] if self[:item_display_struct].blank?

    @items ||= self[:item_display_struct]&.map do |item_display|
      Holdings::Item.new(item_display, document: self)
    end&.sort_by(&:full_shelfkey)

    @items ||= []
  end

  def preferred_item
    @preferred_item ||= begin
      item = self[:preferred_barcode] && (items.reject(&:suppressed?).find do |c|
        c.barcode == self[:preferred_barcode]
      end)

      item || items.first
    end
  end

  attr_writer :preferred_item

  def find_holding(library_code:, location:) # rubocop:disable Lint/UnusedMethodArgument
    folio_holdings.find { |holding| holding.effective_location.library.code == library_code }
  end

  def find_item(barcode:)
    folio_items.find { |item| item.barcode == barcode }
  end

  def folio_holdings
    @folio_holdings ||= Array(holdings_json['holdings']).map { |holding| Folio::Holding.from_dynamic(holding) }
  end

  def folio_items
    @folio_items ||= Array(holdings_json['items']).map do |item|
      holdings_record = folio_holdings_by_id[item['holdingsRecordId']]
      Folio::Item.from_dynamic(item, holdings_record:)
    end
  end

  def holdings_json
    @holdings_json ||= first(:holdings_json_struct).presence || {}
  end

  private

  def folio_holdings_by_id
    @folio_holdings_by_id ||= folio_holdings.index_by(&:id)
  end
end
