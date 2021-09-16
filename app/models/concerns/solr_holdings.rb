module SolrHoldings
  def holdings(live: false)
    @holdings ||= {}
    @holdings[live] ||= Holdings.new(live ? live_lookup_callnumbers : callnumbers, mhld)
  end

  def mhld
    return [] if self[:mhld_display].blank?

    @mhld ||= self[:mhld_display].map do |mhld_display|
      Holdings::MHLD.new(mhld_display)
    end
  end

  def callnumbers
    return [] if self[:item_display].blank?

    @callnumbers ||= self[:item_display].map do |item_display|
      Holdings::Callnumber.new(item_display, document: self)
    end.sort_by(&:full_shelfkey)
  end

  def live_lookup_callnumbers
    @live_lookup_callnumbers ||= callnumbers.map do |item|
      data = live_data_for_barcode(item.barcode)

      if data.present?
        item.current_location = Holdings::Location.new(data['current_location'])
        item.due_date = data['due_date'] if data['due_date']
        item.status = Holdings::Status.new(item)
      end

      item
    end
  end

  def preferred_callnumber
    @preferred_callnumber ||= begin
      callnumber = self[:preferred_barcode] && (callnumbers.select(&:present?).find do |c|
        c.barcode == self[:preferred_barcode]
      end)

      callnumber || callnumbers.first
    end
  end

  private

  def live_data
    @live_data ||= LiveLookup.new(id).records
  end

  def live_data_for_barcode(barcode)
    live_data.find do |item|
      item['barcode'] == barcode
    end
  end
end
