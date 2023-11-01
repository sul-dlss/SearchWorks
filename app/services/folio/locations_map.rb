# frozen_string_literal: true

require 'csv'

module Folio
  # This starts with the location.tsv file provided by libsys. We make any modifications to that data here.
  # This is intended to be a temporary class, which will only be necessary until we complete the Folio migration.
  # TODO: remove after Folio migration
  class LocationsMap
    include Singleton

    # @param [String] library_code the Symphony library
    # @param [String] location_code the Symphony location
    # @return [String] the Folio location code
    def self.for(library_code:, location_code:)
      instance.data.dig(library_code, location_code) || location_code
    end

    def self.symphony_code_for(location_code:)
      instance.reverse_data[location_code]
    end

    def data
      @data ||= load_map
    end

    def reverse_data
      @reverse_data ||= CSV.parse(file_contents, col_sep: "\t").each_with_object({}) do |(home_location, library_code, folio_code), hash|
        # SAL3's CDL/ONORDER/INPROCESS locations are all mapped so SAL3-STACKS
        next if folio_code == 'SAL3-STACKS' && home_location != 'STACKS'

        library_code = 'LANE-MED' if library_code == 'LANE'
        library_code = 'MEDIA-MTXT' if library_code == 'MEDIA-CENTER'

        # Recode SUL-SDR to have "INTERNET" be it's home_locaion
        home_location = 'INTERNET' if home_location == 'SDR'

        hash[folio_code] ||= [library_code, home_location]
      end
    end

    def load_map
      CSV.parse(file_contents, col_sep: "\t").each_with_object({}) do |(home_location, library_code, folio_code), hash|
        hash[library_code] ||= {}
        hash[library_code][home_location] = folio_code
      end
    end

    def file_contents
      Rails.root.join("config/folio/locations.tsv").read
    end
  end
end
