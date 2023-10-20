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
      @reverse_data ||= data.each_with_object({}) do |(symphony_library_code, locations), hash|
        locations.each do |symphony_location_code, folio_location_code|
          hash[folio_location_code] = [symphony_library_code, symphony_location_code]
        end
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
