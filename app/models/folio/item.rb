# frozen_string_literal: true

module Folio
  class Item
    attr_reader :id, :status, :barcode, :call_number, :material_type, :effective_location,
                :permanent_location, :volume, :enumeration, :chronology

    MaterialType = Struct.new(:id, :name, keyword_init: true)
    LoanType = Struct.new(:id, :name, keyword_init: true)
    CallNumber = Data.define(:type_id, :type_name, :call_number) do
      def self.from_dynamic(json)
        new(type_id: json['typeId'], type_name: json['typeName'], call_number: json['callNumber'])
      end
    end

    # rubocop:disable Metrics/ParameterLists
    def initialize(id:, status:, barcode:, material_type:, permanent_loan_type:, effective_location:,
                   call_number:, volume:, enumeration:, chronology:,
                   permanent_location: nil, temporary_loan_type: nil)
      @id = id
      @barcode = barcode
      @status = status
      @material_type = material_type
      @permanent_loan_type = permanent_loan_type
      @effective_location = effective_location
      @permanent_location = permanent_location || effective_location
      @temporary_loan_type = temporary_loan_type
      @call_number = call_number
      @volume = volume
      @enumeration = enumeration
      @chronology = chronology
    end
    # rubocop:enable Metrics/ParameterLists

    def self.from_dynamic(json, holdings_record: nil)
      new(id: json.fetch('id'),
          status: json.fetch('status'),
          barcode: json['barcode'],
          material_type: json['materialTypeId'] && MaterialType.new(
            id: json.fetch('materialTypeId'),
            name: json.fetch('materialType')
          ),
          permanent_loan_type: json['permanentLoanTypeId'] && LoanType.new(
            id: json.fetch('permanentLoanTypeId'),
            name: json.fetch('permanentLoanType')
          ),
          temporary_loan_type: json['temporaryLoanTypeId'] && LoanType.new(
            id: json.fetch('temporaryLoanTypeId'),
            name: json.fetch('temporaryLoanType')
          ),
          volume: json['volume'], # only present for serials
          enumeration: json['enumeration'], # only present for serials
          chronology: json['chronology'], # only present for serials
          call_number: CallNumber.from_dynamic(json['callNumber']),
          effective_location: Folio::Location.from_dynamic(json.dig('location', 'effectiveLocation')),
          permanent_location: (Folio::Location.from_dynamic(json.dig('location', 'permanentLocation')) if json.dig('location', 'permanentLocation')) || holdings_record&.effective_location)
    end

    def constructed_call_number
      [call_number.call_number, volume, enumeration, chronology].compact.join(' ').presence
    end

    def location_provided_availability
      effective_location.details['availabilityClass']
    end

    def loan_type
      @temporary_loan_type || @permanent_loan_type
    end
  end
end
