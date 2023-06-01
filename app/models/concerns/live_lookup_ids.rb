# Mixin that adds an abstraction layer for bib/instance and item ids needed for live lookup
# of availability to account for differences between Sirsi and FOLIO

module LiveLookupIds
  # For Sirsi use the catalog key for availability lookup; for FOLIO use the Instance UUID
  def live_lookup_id
    return self[:uuid_ssi] if Settings.FOLIO_LIVE_LOOKUP && fetch(:uuid_ssi, nil)

    self[:id]
  end

  # TODO: We can remove this and adjust how we get the item id for live lookup after we add
  #   a mapping in searchworks_traject_indexer between barcodes and uuids in each solr document,
  #   either in its own field or as part of the item_display field.
  #
  # @return [Hash] maps item barcodes to item UUIDs or an empty hash if FOLIO_LIVE_LOOKUP is false
  def barcode_to_uuid_mapping
    return {} unless Settings.FOLIO_LIVE_LOOKUP && fetch(:holdings_json_struct, nil)

    JSON.parse(self[:holdings_json_struct].first).fetch('items', []).filter_map do |item|
      [item.fetch('barcode', ''), item.fetch('id', '')]
    end.to_h
  end
end
