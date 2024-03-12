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

  # item_display_struct contains fake items for eresources and boundwiths, which is why we don't use holdings_json_struct directly
  def items
    return [] if self[:item_display_struct].blank?

    @items ||= self[:item_display_struct]&.map do |item_display|
      Holdings::Item.new(item_display, document: self)
    end&.sort_by(&:full_shelfkey)

    @items ||= []
  end

  def browseable_spines
    @browseable_spines ||= if self[:browse_nearby_struct].nil?
                             # Temporarily construct browseable spines from the item_display_struct, until we can get browse_nearby_struct
                             # from the index: https://github.com/sul-dlss/searchworks_traject_indexer/pull/1363
                             browseable_schemes = %w[LC DEWEY ALPHANUM]
                             browseable_items = items.select { |v| v.shelfkey.present? && browseable_schemes.include?(v.callnumber_type) }

                             representative_items = browseable_items.group_by(&:truncated_callnumber).map do |_base_call_number, items|
                               if items.one?
                                 items.first
                               else
                                 items.min_by(&:full_shelfkey)
                               end
                             end

                             representative_items.map do |v|
                               Holdings::Spine.new({
                                                     lopped_call_number: v.truncated_callnumber,
                                                     shelfkey: v.shelfkey,
                                                     reverse_shelfkey: v.reverse_shelfkey,
                                                     callnumber: v.callnumber,
                                                     scheme: v.callnumber_type,
                                                     item_id: v.id
                                                   }, document: self)
                             end
                           else
                             @browseable_spines ||= (self[:browse_nearby_struct] || []).map do |spine_data|
                               Holdings::Spine.new(spine_data, document: self)
                             end
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
