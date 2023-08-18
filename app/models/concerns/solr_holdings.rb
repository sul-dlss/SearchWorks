module SolrHoldings
  def holdings(live: false)
    @holdings ||= {}
    @holdings[live] ||= Holdings.new(live ? live_lookup_items : items, mhld)
  end

  def mhld
    return [] if self[:mhld_display].blank?

    @mhld ||= self[:mhld_display].map do |mhld_display|
      Holdings::MHLD.new(mhld_display)
    end
  end

  # Items can come from either item_display_struct (preferred) or item_display.
  def items
    return [] if self[:item_display].blank? && self[:item_display_struct].blank?

    @items ||= self[:item_display_struct]&.map do |item_display|
      Holdings::Item.new(item_display, document: self)
    end&.sort_by(&:full_shelfkey)

    # legacy implementation until everything that needs it has a item_display_struct
    @items ||= self[:item_display]&.map do |item_display|
      Holdings::Item.from_item_display_string(item_display, document: self)
    end&.sort_by(&:full_shelfkey)

    @items ||= []
  end

  def live_lookup_items
    @live_lookup_items ||= items.map do |item|
      data = live_data_for_barcode(item.barcode)

      if data.present?
        item.current_location = Holdings::Location.new(data['status'], library: item.library)
        item.due_date = data['due_date'] if data['due_date']
        item.status = Holdings::Status.new(item)
      end

      item
    end
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

  def cdl?
    druid && holdings.items.any? { |call| call.home_location == 'CDL' }
  end

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

  private

  def folio_holdings_by_id
    @folio_holdings_by_id ||= folio_holdings.index_by(&:id)
  end

  # Setting this to no-op if live_lookup_service is set to something other than
  # LiveLookup::Sirsi. This is currently used by the request app to get live
  # information about items, but we plan to go directly to FOLIO instead.
  def live_data
    @live_data ||= if Settings.live_lookup_service == 'LiveLookup::Sirsi'
                     LiveLookup.new(id).records
                   else
                     []
                   end
  end

  def live_data_for_barcode(barcode)
    live_data.find do |item|
      item['barcode'] == barcode
    end
  end

  def holdings_json
    @holdings_json ||= self[:holdings_json_struct].present? ? first(:holdings_json_struct) : {}
  end
end
