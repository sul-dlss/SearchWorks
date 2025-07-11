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
      next if original_field.nil? || blacklight_config.facet_fields[k]

      blacklight_config.add_facet_field k, **original_field.to_h, group: 'negative', show: false, label: "#{original_field.label} NOT",
                                                                  filter_query_builder: NegativeFilterQueryBuilder
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
