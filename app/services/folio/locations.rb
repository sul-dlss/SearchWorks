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

    # @param [String] code the Folio location code
    # @return [String] the location's stackmap API URL
    def self.stackmap_api_url(code:)
      instance.data.dig(code, 'details', 'stackmapBaseUrl')
    end

    # Output a CSV of all locations, flattening details and converting UUIDs to codes
    # @return [String] comma-separated data for all locations
    # rubocop:disable Metrics/MethodLength
    def self.to_csv
      headers = %w[id name code institutionCode campusCode libraryCode]
      detail_headers = []

      csv_data = instance.data.each_value.map do |loc|
        # don't mutate original data
        location = loc.dup

        # flatten detail fields
        if location['details'].present?
          location['details'].each do |key, val|
            next if val.blank?

            location["details.#{key}"] = val
            detail_headers |= ["details.#{key}"]
          end
        end

        # look up UUIDs and convert to codes
        location['institutionCode'] = Folio::Types.institutions.dig(location['institutionId'], 'code')
        location['campusCode'] = Folio::Types.campuses.dig(location['campusId'], 'code')
        location['libraryCode'] = Folio::Types.libraries.dig(location['libraryId'], 'code')
        location['primaryServicePointCode'] = Folio::Types.service_points.dig(location['primaryServicePoint'], 'code')
        location['servicePointCodes'] = location['servicePointIds']&.map { |id| Folio::Types.service_points.dig(id, 'code') }

        # remove fields that are now unused
        location.each_key { |key| key.match?(/Ids?$/) && location.delete(key) }
        location.delete('primaryServicePoint') # is a UUID, despite how FOLIO named it
        location.delete('servicePoints') # always empty
        location.delete('metadata')
        location.delete('details')

        # save headers for CSV
        headers |= (location.keys - detail_headers)
        location
      end

      # change the order of the headers so that variable-length object keys are at the end
      headers |= %w[primaryServicePointCode servicePointCodes]
      headers |= detail_headers

      # write CSV; join arrays with semicolons
      CSV.generate do |csv|
        csv << headers
        csv_data.each do |location|
          csv << headers.map do |header|
            case location[header]
            when Array
              location[header].join(';')
            else
              location[header]
            end
          end
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    def data
      @data ||= Folio::Types.locations.values.index_by { |v| v['code'] }
    end
  end
end
