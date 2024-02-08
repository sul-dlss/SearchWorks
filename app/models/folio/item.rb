module Folio
  class Item
    attr_reader :id, :status, :barcode, :material_type, :effective_location, :permanent_location

    MaterialType = Struct.new(:id, :name, keyword_init: true)
    LoanType = Struct.new(:id, :name, keyword_init: true)

    # rubocop:disable Metrics/ParameterLists
    def initialize(id:, status:, barcode:, material_type:, permanent_loan_type:, effective_location:, permanent_location: nil, temporary_loan_type: nil)
      @id = id
      @barcode = barcode
      @status = status
      @material_type = material_type
      @permanent_loan_type = permanent_loan_type
      @effective_location = effective_location
      @permanent_location = permanent_location || effective_location
      @temporary_loan_type = temporary_loan_type
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
          effective_location: Folio::Location.from_dynamic(json.dig('location', 'effectiveLocation')),
          permanent_location: (Folio::Location.from_dynamic(json.dig('location', 'permanentLocation')) if json.dig('location', 'permanentLocation')) || holdings_record&.effective_location)
    end

    def location_provided_availability
      effective_location.details['availabilityClass']
    end

    def loan_type
      @temporary_loan_type || @permanent_loan_type
    end
  end
end
