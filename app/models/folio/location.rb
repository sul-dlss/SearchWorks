module Folio
  class Location
    def initialize(library_code:)
      @library_code = library_code
    end

    def self.from_dynamic(json)
      new(library_code: json.fetch('library').fetch('code'))
    end
    attr_reader :library_code
  end
end
