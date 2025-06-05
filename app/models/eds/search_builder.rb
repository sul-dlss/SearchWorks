# frozen_string_literal: true

module Eds
  # Map Blacklight's search parameters to EDS request parameters
  class SearchBuilder < Blacklight::SearchBuilder
    self.default_processor_chain = %i[add_default_parameters add_date_slider add_query_parameters add_sort_parameter add_facet_parameters add_limiters add_pagination]

    def add_default_parameters(eds_params)
      eds_params[:RetrievalCriteria] = { View: 'detailed' }
      eds_params[:SearchCriteria] = { SearchMode: 'all', IncludeFacets: 'y', Sort: 'relevance' }
    end

    def add_date_slider(eds_params)
      return unless blacklight_params[:range]

      begin_year = blacklight_params.dig('range', 'pub_year_tisim', 'begin')
      end_year = blacklight_params.dig('range', 'pub_year_tisim', 'end')

      return if begin_year.blank? && end_year.blank?

      pub_year_tisim_range = "#{begin_year}-01/#{end_year}-01"

      eds_params[:SearchCriteria][:Limiters] ||= []
      eds_params[:SearchCriteria][:Limiters] << { Id: 'DT1', Values: [pub_year_tisim_range] }
    end

    def add_query_parameters(eds_params)
      eds_params[:SearchCriteria][:Queries] = if search_field.eds_field_code
                                                [{ Term: blacklight_params[:q], FieldCode: search_field.eds_field_code }]
                                              else
                                                [{ Term: blacklight_params[:q] }]
                                              end
    end

    def add_sort_parameter(eds_params)
      eds_params[:SearchCriteria][:Sort] = sort
    end

    def add_facet_parameters(eds_params)
      eds_params[:SearchCriteria][:FacetFilters] ||= [] if search_state.filters.any?

      filters = search_state.filters.reject { |filter| filter.config.eds_limiter }.flat_map do |filter|
        filter.values.compact_blank.map do |v|
          { Id: filter.config.field, Value: v }
        end
      end

      filters.each_with_index do |filter, index|
        eds_params[:SearchCriteria][:FacetFilters] << {
          FilterId: index,
          FacetValues: [filter]
        }
      end
    end

    def add_limiters(eds_params)
      search_state.filters.select { |filter| filter.config.eds_limiter }.each do |filter|
        eds_params[:SearchCriteria][:Limiters] ||= []
        available_select_limiters.select { |limiter| limiter['Label'].in?(filter.values) || limiter['Id'].in?(filter.values) }.each do |limiter|
          eds_params[:SearchCriteria][:Limiters] << {
            Id: limiter['Id'],
            Values: ['y']
          }
        end
      end
    end

    def available_select_limiters
      info.dig('AvailableSearchCriteria', 'AvailableLimiters').select { |limiter| limiter['Type'] == 'select' }
    end

    def add_pagination(eds_params)
      # @View = info.default_result_list_view
      eds_params[:RetrievalCriteria][:ResultsPerPage] = blacklight_params[:per_page]&.to_i || blacklight_config.default_per_page
      eds_params[:RetrievalCriteria][:PageNumber] = blacklight_params[:page]&.to_i || 1
    end

    def info
      @info ||= blacklight_config.repository.connection.info
    end
  end
end
