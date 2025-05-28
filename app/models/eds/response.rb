module Eds
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

    def aggregations
      {}
    end

    def documents
      @documents ||= (dig('SearchResult', 'Data', 'Records') || []).map { |doc| document_factory.build(doc, self, options) }
    end
    alias docs documents
  end
end
