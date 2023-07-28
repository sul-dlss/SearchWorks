# frozen_string_literal: true

require 'csv'

module Folio
  # This reads the locations.json file exported from Folio.
  class Locations
    include Singleton

    # @param [String] code the Folio location code
    # @return [String] the Folio location label
    def self.label(code:)
      instance.data.dig(code, 'discoveryDisplayName')
    end

    def data
      @data ||= Folio::Types.locations.values.index_by { |v| v['code'] }
    end
  end
end
