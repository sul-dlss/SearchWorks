# frozen_string_literal: true

module Eds
  ##
  # Responsible for parsing an EDS flavored Blacklight::Solr::Response for
  # convenient accessors
  class DateRangeParser
    attr_reader :response, :params, :solr_field

    ##
    # @param [Blacklight::Solr::Response] response
    # @param [ActionController::Parameters] params
    # @param [String] solr_field
    def initialize(response, params, solr_field)
      @response = response
      @params = params
      @solr_field = solr_field
    end

    def begin
      request_range['begin'] || min_year
    end

    def end
      request_range['end'] || max_year
    end

    def min_year
      date_range['minyear']
    end

    def max_year
      date_range['maxyear']
    end

    def request_range
      params.fetch(:range, {}).fetch(solr_field.to_sym, {})
    end

    private

    ##
    # Acccessing from https://github.com/ebsco/edsapi-ruby/blob/bc825c1d89844bab2936c51d4b827c4fd1ddde97/lib/ebsco/eds/results.rb#L527
    def date_range
      response['date_range']
    end
  end
end
