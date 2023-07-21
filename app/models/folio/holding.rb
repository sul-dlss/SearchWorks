module Folio
  class Holding
    attr_reader :id, :effective_location, :holdings_type

    def initialize(id:, effective_location:, holdings_type:)
      @id = id
      @effective_location = effective_location
      @holdings_type = holdings_type
    end

    def bound_with?
      holdings_type == 'Bound-with'
    end

    def self.from_dynamic(json)
      new(id: json.fetch('id'),
          effective_location: Folio::Location.from_dynamic(json.dig('location', 'effectiveLocation')),
          holdings_type: json.dig('holdingsType', 'code'))
    end
  end
end
