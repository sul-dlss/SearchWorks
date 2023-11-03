# frozen_string_literal: true

require 'csv'

module Folio
  # This starts with the location.tsv file provided by libsys. We make any modifications to that data here.
  # This is intended to be a temporary class, which will only be necessary until we complete the Folio migration.
  # TODO: remove after Folio migration
  class LocationsMap
    include Singleton

    # @param [String] location_code the FOLIO location
    # @return [String] the Symphony location code
    def self.symphony_code_for(location_code:)
      instance.folio_to_symphony_map[location_code]
    end

    def folio_to_symphony_map
      @folio_to_symphony_map ||= CSV.parse(file_contents, col_sep: "\t").each_with_object({}) do |(home_location, library_code, folio_code), hash|
        # SAL3's CDL/ONORDER/INPROCESS locations are all mapped so SAL3-STACKS
        next if folio_code == 'SAL3-STACKS' && home_location != 'STACKS'

        library_code = 'LANE-MED' if library_code == 'LANE'
        library_code = 'MEDIA-MTXT' if library_code == 'MEDIA-CENTER'

        # Recode SUL-SDR to have "INTERNET" be it's home_locaion
        home_location = 'INTERNET' if home_location == 'SDR'

        hash[folio_code] ||= [library_code, home_location]
      end
    end

    def file_contents
      Rails.root.join("config/folio/locations.tsv").read
    end
  end
end
