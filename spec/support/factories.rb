# frozen_string_literal: true

class Factories
  module Methods
    def build(type, ...)
      # If we don't support this factory, maybe factory_bot does.
      Factories.supported_type?(type) ? Factories.build(type, ...) : super
    end
  end

  SUPPORTED_TYPES = %i[
    location
  ].freeze

  def self.supported_type?(type)
    SUPPORTED_TYPES.include?(type)
  end

  def self.build(type, ...)
    public_send(:"build_#{type}", ...)
  end

  def self.build_location(code: 'GRE-STACKS')
    folio_loc = Folio::Locations.find_by(code:)
    library_id = folio_loc.fetch('libraryId')
    library = build_library(**Folio::Types.libraries[library_id].symbolize_keys.slice(:id, :code))
    institution = build_institution
    campus = build_campus

    {
      id: folio_loc.fetch('id'),
      code:,
      name: folio_loc.fetch('name'),
      campus:,
      details: {},
      library:,
      isActive: true,
      institution:
    }
  end

  def self.build_library(id: 'library-id', code: 'GREEN')
    {
      id:,
      code:,
      name: "Fake library name"
    }
  end

  def self.build_institution
    {
      id: "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
      code: "SU",
      name: "Stanford University"
    }
  end

  def self.build_campus(code: 'SUL')
    {
      id: "c365047a-51f2-45ce-8601-e421ca3615c5",
      code:,
      name: "Stanford Libraries"
    }
  end
end
