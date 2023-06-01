# Mixin that adds an abstraction layer for bib/instance ids needed for live lookup
# of availability to account for differences between Sirsi and FOLIO

module LiveLookupIds
  # For Sirsi use the catalog key for availability lookup; for FOLIO use the Instance UUID
  def live_lookup_id
    self[:uuid_ssi] || self[:id]
  end
end
