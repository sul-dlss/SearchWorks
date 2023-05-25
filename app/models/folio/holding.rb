module Folio
  class Holding
    attr_reader :id, :effective_location

    def initialize(id:, effective_location:)
      @id = id
      @effective_location = effective_location
    end

    def self.from_dynamic(json)
      new(id: json.fetch('id'),
          effective_location: Folio::Location.from_dynamic(json.dig('location', 'effectiveLocation')))
    end
  end
end
