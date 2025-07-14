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

  class NegativeFilterQueryBuilder < Blacklight::Solr::AbstractFilterQueryBuilder
    def call(filter, *)
      facet_config = blacklight_config.facet_fields[filter.config.key]
      solr_field = facet_config.field if facet_config && !facet_config.query
      solr_field ||= filter.config.key

      negated_queries = filter.values.compact_blank.map do |value|
        "-#{solr_field}:\"#{value}\""
      end

      [negated_queries, {}]
    end
  end
end
