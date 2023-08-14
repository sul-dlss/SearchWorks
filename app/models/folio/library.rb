module Folio
  # Library information in FOLIO
  class Library
    attr_reader :id, :code

    def initialize(id:, code:, name: nil)
      @id = id
      @code = code
      @name = name
    end

    def name
      cached_data&.dig('name') || @name
    end

    def cached_data
      Folio::Types.libraries[id] || {}
    end
  end
end
