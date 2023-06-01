module Folio
  # Location information in FOLIO, combining institution/campus/library/location
  class Location
    Institution = Struct.new(:id, :code, :name, keyword_init: true)
    Campus = Struct.new(:id, :code, :name, keyword_init: true)
    Library = Struct.new(:id, :code, :name, keyword_init: true)
    Location = Struct.new(:id, :code, :name, keyword_init: true)

    # Institution for all Stanford records, including coordinate libraries/campuses
    SU = Institution.new(id: '8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929', code: 'SU', name: 'Stanford University')

    attr_reader :institution, :campus, :library, :location

    delegate :id, :code, :name, to: :location

    def initialize(campus:, library:, location:, institution: SU)
      @institution = institution
      @campus = campus
      @library = library
      @location = location
    end

    def self.from_dynamic(json)
      new(institution: Institution.new(**json.fetch('institution')),
          campus: Campus.new(**json.fetch('campus')),
          library: Library.new(**json.fetch('library')),
          location: Location.new(id: json.fetch('id'),
                                 code: json.fetch('code'),
                                 name: json.fetch('name')))
    end
  end
end
