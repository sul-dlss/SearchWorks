# Mixin that adds an abstraction layer for bib/instance ids needed for live lookup availability

module LiveLookupIds
  # for FOLIO use the Instance UUID
  def live_lookup_id
    self[:uuid_ssi]
  end
end
