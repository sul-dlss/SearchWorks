# frozen_string_literal: true

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

  # item_display_struct contains fake items boundwiths, which is why we don't use holdings_json_struct directly
  def items
    return [] if self[:item_display_struct].blank?

    @items ||= self[:item_display_struct]&.map do |item_display|
      Holdings::Item.new(item_display, document: self)
    end&.sort_by(&:full_shelfkey)

    @items ||= []
  end

  def browseable_spines
    @browseable_spines ||= (self[:browse_nearby_struct] || []).map do |spine_data|
      Holdings::Spine.new(spine_data, document: self)
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

  def with_preferred_item(item)
    @preferred_item = item
    self
  end

  def folio_holdings
    @folio_holdings ||= Array(holdings_json['holdings']).map { |holding| Folio::Holding.from_dynamic(holding) }
  end

  def folio_items
    @folio_items ||= Array(holdings_json['items']).map do |item|
      holdings_record = folio_holdings_by_id[item['holdingsRecordId']]
      Folio::Item.from_dynamic(item, holdings_record:)
    end.sort_by(&:effective_shelving_order)
  end

  def bound_with_folio_items
    @bound_with_folio_items ||= folio_holdings.filter_map do |holdings_record|
      next unless holdings_record.bound_with_parent

      Folio::Item.from_dynamic(holdings_record.bound_with_parent.item, holdings_record: holdings_record)
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
