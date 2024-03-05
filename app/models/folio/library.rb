module Folio
  # Library information in FOLIO
  class Library
    attr_reader :id, :code

    def self.find_by(code: nil)
      library_data = data[code]
      return unless library_data

      new(**library_data.slice('id', 'code', 'name').symbolize_keys, library_data:)
    end

    def self.data
      @data ||= Folio::Types.libraries.values.index_by { |v| v['code'] }
    end

    def initialize(id:, code:, name: nil, library_data: nil)
      @id = id
      @code = code
      @name = name
      @cached_data = library_data
    end

    def name
      cached_data&.dig('name') || @name
    end

    def cached_data
      @cached_data ||= Folio::Types.libraries[id] || {}
    end
  end
end
