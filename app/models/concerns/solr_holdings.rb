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

  def items
    return [] if self[:item_display].blank?

    @items ||= self[:item_display].map do |item_display|
      Holdings::Item.new(item_display, document: self)
    end.sort_by(&:full_shelfkey)
  end

  # TODO: This will need to be updated to do FOLIO lookups
  def live_lookup_items
    @live_lookup_items ||= items.map do |item|
      data = live_data_for_barcode(item.barcode)

      if data.present?
        item.current_location = Holdings::Location.new(data['current_location'])
        item.due_date = data['due_date'] if data['due_date']
        item.status = Holdings::Status.new(item)
      end

      item
    end
  end

  def preferred_item
    @preferred_item ||= begin
      item = self[:preferred_barcode] && (items.select(&:present?).find do |c|
        c.barcode == self[:preferred_barcode]
      end)

      item || items.first
    end
  end

  attr_writer :preferred_item

  def cdl?
    druid && holdings.items.any? { |call| call.home_location == 'CDL' }
  end

  private

  # TODO: This will need to hit the live availability lookup?
  def live_data
    @live_data ||= SirsiLiveLookup.new(id).records
  end

  def live_data_for_barcode(barcode)
    live_data.find do |item|
      item['barcode'] == barcode
    end
  end
end
