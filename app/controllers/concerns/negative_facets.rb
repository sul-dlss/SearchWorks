# frozen_string_literal: true

##
# A mixin to add dynamic negative facet support
module NegativeFacets
  extend ActiveSupport::Concern

  included do
    before_action :add_negative_facet_fields, only: [:index, :facet] if respond_to?(:before_action) # rubocop:disable Rails/LexicallyScopedActionFilter
  end

  protected

  def add_negative_facet_fields
    return unless params[:f]

    params[:f].select { |k, _v| k.start_with?('-') }.each_key do |k|
      original_field = blacklight_config.facet_fields[k.delete_prefix('-')]
      next unless original_field

      blacklight_config.facet_fields[k] = original_field.dup
      blacklight_config.facet_fields[k].key = k
      blacklight_config.facet_fields[k].show = false
      blacklight_config.facet_fields[k].label = "#{original_field.label} NOT"

      blacklight_config.facet_fields[k].filter_query_builder = NegativeFilterQueryBuilder
    end
  end

  class NegativeFilterQueryBuilder < Blacklight::Solr::DefaultFilterQueryBuilder
    def call(filter, *)
      filter_queries, subqueries = super

      negated_queries = filter_queries.map do |query|
        if query.start_with?('-')
          query.delete_prefix('-')
        else
          "-#{query}"
        end
      end

      [negated_queries, subqueries]
    end
  end
end
