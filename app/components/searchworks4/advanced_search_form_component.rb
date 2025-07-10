# frozen_string_literal: true

module Searchworks4
  class AdvancedSearchFormComponent < Blacklight::AdvancedSearchFormComponent
    delegate :search_state, to: :helpers
    # don't need any of the upstream functionality
    def before_render; end

    def search_fields
      blacklight_config.search_fields.select { |_, v| helpers.should_render_field?(v) }.map { |_key, f| { field: f.key, label: helpers.label_for_search_field(f.key) } }
    end

    def search_filter_controls
      fields = blacklight_config.facet_fields.select { |_k, v| v.include_in_advanced_search || (v.include_in_advanced_search.nil? && helpers.should_render_field?(v)) }

      fields.sort_by { |_k, config| helpers.facet_field_label(config.key) }.select { |field| helpers.should_render_field?(field) }.map do |_key, config|
        display_facet = @response.aggregations[config.field]
        values = (config.limit || 0) < 50 ? [] : display_facet.items

        { field: config.key, label: helpers.facet_field_label(config.key), limit: config.limit, range: config.range, top: config.key.in?(blacklight_config.top_filters[:advanced_search]),
          values: values }
      end
    end
  end
end
