# LiveLookup serves as a wrapper around specific ILS implementations
#   for requesting live information about item availability.
class LiveLookup
  delegate :as_json, :to_json, to: :records

  def initialize(ids)
    @ids = [ids].flatten.compact
  end

  # Uses either the Folio or Sirsi LiveLookup service
  # depending on whether FOLIO_LIVE_LOOKUP is set.
  def records
    if Settings.FOLIO_LIVE_LOOKUP
      LiveLookup::Folio.new(@ids).records
    else
      LiveLookup::Sirsi.new(@ids).records
    end
  end
end
