# frozen_string_literal: true

require 'csv'

module Folio
  # This reads the locations.json file exported from Folio.
  class Locations
    include Singleton

    # @param [String] code the Folio location code
    # @return [String] the Folio location label
    def self.label(code:)
      instance.data[code]
    end

    def data
      @data ||= load_map
    end

    def load_map
      JSON.parse(file_contents).each_with_object({}) do |(location), hash|
        hash[location.fetch('code')] = location.fetch('discoveryDisplayName')
      end
    end

    def file_contents
      Rails.root.join("config/folio/locations.json").read
    end
  end
end
