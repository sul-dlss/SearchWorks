module Folio
  # Location information in FOLIO, combining institution/campus/library/location
  class Location
    Institution = Struct.new(:id, :code, :name, keyword_init: true)
    Campus = Struct.new(:id, :code, :name, keyword_init: true)
    Library = Struct.new(:id, :code, :name, keyword_init: true)

    # Institution for all Stanford records, including coordinate libraries/campuses
    SU = Institution.new(id: '8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929', code: 'SU', name: 'Stanford University')

    attr_reader :institution, :campus, :library

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

    def self.from_dynamic(json)
      new(institution: Institution.new(**json.fetch('institution').slice('id', 'code', 'name')),
          campus: Campus.new(**json.fetch('campus').slice('id', 'code', 'name')),
          library: Library.new(**json.fetch('library').slice('id', 'code', 'name')),
          id: json.fetch('id'),
          code: json.fetch('code'),
          name: json.fetch('name'))
    end

    def see_other?
      code.ends_with?('-SEE-OTHER')
    end
  end
end
