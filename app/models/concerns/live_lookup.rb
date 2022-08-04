# Mixin that adds an abstraction layer for IDs needed for live lookup of availability
# as we migrate from Sirsi to FOLIO

module LiveLookup
  REQUIRED_HOLDINGS_FIELDS = %w[barcode id].freeze

  # For Sirsi use the bib id for availability lookup; for FOLIO use the Instance UUID
  def live_lookup_id
    return self[:uuid_ssi] if Settings.FOLIO_LIVE_LOOKUP && fetch(:uuid_ssi, nil)

    self[:id]
  end

  # For Sirsi use the item barcode to match items with availability info;
  # for FOLIO use the Item UUID
  #
  # This method returns a hash that maps barcodes to FOLIO UUIDs
  def barcodes_uuids
    return {} unless Settings.FOLIO_LIVE_LOOKUP && fetch(:holdings_json_struct, nil)

    JSON.parse(self[:holdings_json_struct].first).fetch('items', []).filter_map do |item|
      [item['barcode'], item['id']] if REQUIRED_HOLDINGS_FIELDS.all? { |s| item.key?(s) }
    end.to_h
  end
end
