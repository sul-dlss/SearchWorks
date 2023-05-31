# LiveLookup serves as a wrapper around specific ILS implementations
#   for requesting live information about item availability.
class LiveLookup
  delegate :as_json, :to_json, to: :records

  def initialize(ids)
    @ids = [ids].flatten.compact
  end

  # Will provide a seam to switch between Sirsi and Folio
  # client lookups dependent on application settings.
  def records
    LiveLookup::Sirsi.new(@ids).records
  end
end
