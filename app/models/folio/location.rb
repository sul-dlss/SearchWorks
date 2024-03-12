# frozen_string_literal: true

module Folio
  # Location information in FOLIO, combining institution/campus/library/location
  class Location
    Institution = Struct.new(:id, :code, :name, keyword_init: true)
    Campus = Struct.new(:id, :code, :name, keyword_init: true)
    Library = Struct.new(:id, :code, :name, keyword_init: true)

    # Institution for all Stanford records, including coordinate libraries/campuses
    SU = Institution.new(id: '8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929', code: 'SU', name: 'Stanford University')

    attr_reader :id, :code, :institution, :campus, :library

    # rubocop:disable Metrics/ParameterLists
    def initialize(id:, code:, campus:, library:, name: nil, institution: SU)
      @id = id
      @code = code
      @name = name
      @institution = institution
      @campus = campus
      @library = library
    end
    # rubocop:enable Metrics/ParameterLists

    # Prefer the locally cached name, but fall back to the name from the document if we have to
    # The name in the document is the "discoveryDisplayName", which may differ from "name"
    def name
      cached_location_data&.dig('name') || @name
    end

    def details
      cached_location_data&.dig('details') || {}
    end

    def self.from_dynamic(json)
      new(institution: Institution.new(**json.fetch('institution').slice('id', 'code', 'name')),
          campus: Campus.new(**json.fetch('campus').slice('id', 'code', 'name')),
          library: Folio::Library.new(**json.fetch('library').slice('id', 'code', 'name').symbolize_keys),
          id: json.fetch('id'),
          code: json.fetch('code'),
          name: json.fetch('name'))
    end

    def see_other?
      code.ends_with?('-SEE-OTHER')
    end

    def cached_location_data
      Folio::Types.locations[id] || {}
    end
  end
end
