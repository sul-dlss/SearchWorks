# frozen_string_literal: true

module Searchworks4
  class AdvancedSearchFormComponent < Blacklight::AdvancedSearchFormComponent
    delegate :search_state, to: :helpers
    # don't need any of the upstream functionality
    def before_render; end

    def search_fields
      possible_search_fields = blacklight_config.search_fields.select do |_, v|
        helpers.should_render_field?(v) || v.include_in_advanced_search
      end

      possible_search_fields.map { |_key, f| { field: f.key, label: helpers.label_for_search_field(f.key) } }
    end

    def search_filter_controls
      fields = blacklight_config.facet_fields.select { |_k, v| v.include_in_advanced_search || (v.include_in_advanced_search.nil? && helpers.should_render_field?(v)) }

      fields.sort_by { |_k, config| helpers.facet_field_label(config.key) }.select { |field| helpers.should_render_field?(field) }.map do |_key, config|
        display_facet = @response.aggregations[config.field]
        facet_presenter = config.presenter.new(config, display_facet, helpers)
        values = (config.limit || 0) < 50 ? [] : display_facet.items
        value_labels = display_facet.items.to_h do |item|
          key = item.value
          label = config.item_presenter.new(item, config, helpers, config.key).label

          [key, label]
        end.compact_blank

        { field: config.key, label: config.advanced_search_label || facet_presenter.label,
          limit: config.limit, range: config.range, top: config.key.in?(blacklight_config.top_filters[:advanced_search]),
          values: values, value_labels: value_labels }
      end
    end
  end
end
