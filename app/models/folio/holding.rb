module Folio
  class Holding
    def initialize(id:, effective_location:)
      @id = id
      @effective_location = effective_location
    end

    def self.from_dynamic(json)
      new(id: json.fetch('id'),
          effective_location: Location.from_dynamic(json.fetch('location').fetch('effectiveLocation')))
    end

    attr_reader :id, :effective_location
  end
end
