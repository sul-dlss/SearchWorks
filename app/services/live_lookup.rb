# frozen_string_literal: true

# LiveLookup serves as a wrapper around specific ILS implementations
# for requesting live information about item availability.
class LiveLookup
  delegate :as_json, :to_json, to: :records

  def initialize(ids)
    @ids = [ids].flatten.compact
  end

  # Uses the LiveLookup service specified by Settings.live_lookup_service
  def records
    live_lookup_service.new(@ids).records
  end

  private

  def live_lookup_service
    Settings.live_lookup_service.constantize
  end
end
