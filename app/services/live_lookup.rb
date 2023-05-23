class LiveLookup
  delegate :as_json, :to_json, to: :records

  def initialize(ids)
    @ids = [ids].flatten.compact
  end

  # NOTE: Will provide an entry point for switching between Sirsi and Folio 
  #       providers for live availability checks so rest of the app doesn't
  #       need to care which provider is configured.
  def records
    LiveLookup::Sirsi.new(@ids).records
  end
end
