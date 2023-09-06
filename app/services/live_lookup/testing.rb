# frozen_string_literal: true

# LiveLookup::Testing just returns a stub response.
class LiveLookup
  class Testing
    delegate :as_json, :to_json, to: :records

    def initialize(_instance_ids); end

    # @return [Array] a blank array
    def records
      []
    end
  end
end
