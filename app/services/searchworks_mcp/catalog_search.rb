# frozen_string_literal: true

module SearchworksMcp
  # Catalog search functionality exposed through MCP.
  module CatalogSearch
    extend self

    MAX_QUERY_LENGTH = 1000
    MAX_FILTER_VALUE_LENGTH = 500

    SEARCH_FIELDS = {
      "all_fields" => "search",
      "title" => "search_title",
      "author" => "search_author",
      "subject" => "subject_terms"
    }.freeze

    def build_input_schema
      properties = {
        query: {
          type: "string",
          description: "The search query to find materials in the catalog",
          minLength: 1,
          maxLength: MAX_QUERY_LENGTH
        },
        search_field: {
          type: "string",
          description: "The field to search in",
          enum: SEARCH_FIELDS.keys,
          default: "all_fields"
        },
        rows: {
          type: "integer",
          description: "Number of results to return (max 20)",
          minimum: 1,
          maximum: 20,
          default: 10
        }
      }
      facet_properties = facet_options.transform_values do |options|
        { type: "string", description: options[:description], maxLength: MAX_FILTER_VALUE_LENGTH }
      end
      properties[:filters] = filter_schema(facet_properties) if facet_properties.any?

      { properties: properties, required: ["query"], additionalProperties: false }
    end

    def search(query:, search_field: "all_fields", rows: 10, filters: {}, controller: nil)
      config = CatalogController.blacklight_config
      params = search_params(query, search_field, rows, filters, config)
      state = Blacklight::SearchState.new(params, config, controller)
      response = Blacklight::SearchService.new(config: config, search_state: state).search_results

      CatalogResults.format(
        response: response,
        query: query,
        search_field: search_field,
        filters: filters || {},
        config: config
      )
    rescue StandardError => e
      SearchworksMcp.internal_tool_error(e, public_message: "Catalog search is temporarily unavailable.")
    end

    private

    def facet_options
      CatalogController.blacklight_config.facet_fields.each_with_object({}) do |(field_name, config), options|
        next unless usable_facet?(config)

        options[clean_label(config.label)] = {
          field: field_name,
          description: "Filter by #{config.label.downcase}"
        }
      end
    end

    def usable_facet?(config)
      config.show != false && config.label.present? && config.query.blank? && config.pivot.blank? && config.range != true
    end

    def clean_label(label)
      label.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/^_|_$/, "")
    end

    def filter_schema(properties)
      {
        type: "object",
        description: "Optional filters to narrow search results",
        properties: properties,
        additionalProperties: false
      }
    end

    def search_params(query, search_field, rows, filters, config)
      {
        q: query,
        search_field: SEARCH_FIELDS.fetch(search_field, "search"),
        rows: [rows, 20].min
      }.tap do |params|
        params[:f] = mapped_filters(filters, config) if filters.present?
      end
    end

    def mapped_filters(filters, config)
      filters.each_with_object({}) do |(key, value), mapped|
        field = config.facet_fields.find do |_field_name, field_config|
          label = field_config.label
          label.present? && clean_label(label) == key.to_s
        end
        next unless field

        field_name, field_config = field
        mapped[field_config.field || field_name] = [value]
      end
    end
  end
end
