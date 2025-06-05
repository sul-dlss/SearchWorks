# frozen_string_literal: true

module Eds
  # Map EDS responses to Blacklight's model
  class Response < ActiveSupport::HashWithIndifferentAccess
    include Kaminari::PageScopeMethods
    include Kaminari::ConfigurationMethods::ClassMethods

    attr_reader :request_params, :search_builder
    attr_accessor :blacklight_config, :options

    delegate :document_factory, to: :blacklight_config

    def initialize(data, request_params, options = {})
      @search_builder = request_params if request_params.is_a?(Blacklight::SearchBuilder)

      super(ActiveSupport::HashWithIndifferentAccess.new(data))
      @request_params = ActiveSupport::HashWithIndifferentAccess.new(request_params)
      self.blacklight_config = options[:blacklight_config]
      self.options = options
    end

    def header
      self['responseHeader'] || {}
    end

    def response
      {
        numFound: size
      }
    end

    def grouped?
      false
    end

    def spelling
      nil
    end

    # short cut to response['numFound']
    def total
      response[:numFound].to_s.to_i
    end

    def start
      search_builder&.start.to_i
    end

    def rows
      search_builder&.rows.to_i
    end

    def empty?
      total.zero?
    end

    def limit_value # :nodoc:
      rows
    end

    def offset_value # :nodoc:
      start
    end

    def total_count # :nodoc:
      total
    end

    ##
    # Should return response documents size, not hash size
    def size
      dig('SearchResult', 'Statistics', 'TotalHits')
    end

    ##
    # Meant to have the same signature as Kaminari::PaginatableArray#entry_name
    def entry_name(options)
      I18n.t('blacklight.entry_name.default', count: options[:count])
    end

    class FacetField
      attr_reader :name, :items, :options

      def initialize(name, items, options = {})
        @name = name
        @items = items
        @options = options
      end

      def sort = nil
      def offset = 0
      def prefix = nil
    end

    FacetValue = Struct.new(:value, :hits, keyword_init: true)

    def aggregations
      available_facets_aggregations
    end

    def available_facets_aggregations
      @available_facets_aggregations ||= (dig('SearchResult', 'AvailableFacets') || []).index_by { |facet| facet['Id'] }.transform_values do |facet|
        values = facet['AvailableFacetValues'].map do |value|
          FacetValue.new(value: value['Value'], hits: value['Count'])
        end
        FacetField.new(facet['Id'], values)
      end
    end

    def date_range_stats
      mindate = dig('SearchResult', 'AvailableCriteria', 'DateRange', 'MinDate')
      maxdate = dig('SearchResult', 'AvailableCriteria', 'DateRange', 'MaxDate')

      return { minyear: nil, maxyear: nil } if mindate.blank? || maxdate.blank?

      minyear = mindate[0..3].to_i
      maxyear = maxdate[0..3].to_i

      # cap maxdate/maxyear to current year + 1 (to filter any erroneous database metadata)
      current_year = Time.zone.now.year
      maxyear = current_year + 1 if maxyear > current_year

      { minyear: minyear.to_s, maxyear: maxyear.to_s }
    end

    def documents
      @documents ||= (dig('SearchResult', 'Data', 'Records') || []).map { |doc| document_factory.build(doc, self, options) }
    end
    alias docs documents
  end
end
