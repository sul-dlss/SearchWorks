# frozen_string_literal: true

module SearchworksMcp
  # Catalog search functionality exposed through MCP.
  module CatalogSearch
    extend self

    MAX_QUERY_LENGTH = 1000
    MAX_FILTER_VALUE_LENGTH = 500

    FilterFacet = Data.define(:label, :config_key, :solr_field)

    # Highlight the catch-all text fields so clients can see why each record matched,
    # without adding large stored fields (e.g. MARC notes) to the search fl.
    HIGHLIGHT_PARAMS = {
      hl: true,
      'hl.method': "unified",
      'hl.fl': "all_search,vern_all_search",
      'hl.snippets': 3,
      'hl.fragsize': 160,
      'hl.tag.pre': "**",
      'hl.tag.post': "**"
    }.freeze

    SEARCH_FIELDS = {
      "all_fields" => "search",
      "title" => "search_title",
      "author" => "search_author",
      "subject" => "subject_terms"
    }.freeze

    # Descriptions for filters whose values aren't obvious from the facet label, keyed by filter name.
    FILTER_DESCRIPTIONS = {
      "topic" => "Filter by subject heading. Most values are Library of Congress headings without subdivisions: " \
                 "personal names with dates (e.g. \"Shakespeare, William, 1564-1616\"), organizations, titles of works, " \
                 "or topical terms (e.g. \"Climate change\", \"Art, Modern\"). Some recent books also have broad BISAC " \
                 "categories in all caps (e.g. \"HISTORY\", \"FICTION\"), which are separate values from their LC " \
                 "equivalents. Geographic headings are not included. Values are case-sensitive and must match exactly; choose them from " \
                 "returned facets.",
      "genre" => "Filter by genre or form: what the item is rather than what it is about. Values come from genre/form " \
                 "headings (e.g. \"Science fiction\", \"Graphic novels\", \"Documentary films\") and from form " \
                 "subdivisions of subject headings (e.g. \"Biography\", \"Juvenile literature\", \"Periodicals\", " \
                 "\"Early works to 1800\"). Values are case-sensitive and must match exactly; choose them from returned facets."
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
          description: "The field to search in (defaults to all_fields)",
          enum: SEARCH_FIELDS.keys
        },
        rows: {
          type: "integer",
          description: "Number of results to return (defaults to 10, max 20)",
          minimum: 1,
          maximum: 20
        }
      }
      facet_properties = filter_facets(CatalogController.blacklight_config).to_h do |name, facet|
        description = FILTER_DESCRIPTIONS.fetch(name) { "Filter by #{facet.label.downcase}" }
        [name, { type: "string", description: description, maxLength: MAX_FILTER_VALUE_LENGTH }]
      end
      properties[:filters] = filter_schema(facet_properties) if facet_properties.any?

      { properties: properties, required: ["query"], additionalProperties: false }
    end

    def search(query:, search_field: "all_fields", rows: 10, filters: {}, controller: nil)
      config = CatalogController.blacklight_config
      params = search_params(query, search_field, rows, filters, config)
      response = run_search(params, config, controller)
      unfiltered_response = unfiltered_search(response, params, config, controller)

      CatalogResults.format(
        response: response,
        query: query,
        search_field: search_field,
        filters: filters || {},
        config: config,
        unfiltered_response: unfiltered_response
      )
    rescue StandardError => e
      SearchworksMcp.internal_tool_error(e, public_message: "Catalog search is temporarily unavailable.")
    end

    # Facets clients can filter on, keyed by filter name (e.g. "format"). Blacklight filter params use
    # config_key; Solr facet params and responses use solr_field (e.g. "library" vs "library_code_facet_ssim").
    def filter_facets(config)
      config.facet_fields.values.each_with_object({}) do |facet, facets|
        next unless usable_facet?(facet)

        facets[clean_label(facet.label)] = FilterFacet.new(label: facet.label, config_key: facet.key, solr_field: facet.field)
      end
    end

    private

    def run_search(params, config, controller)
      state = Blacklight::SearchState.new(params, config, controller)
      Blacklight::SearchService.new(config: config, search_state: state).search_results do |builder|
        builder.merge(HIGHLIGHT_PARAMS.merge(facet_params(config)))
      end
    end

    # Only request facets clients can filter on, with their most common values rather than the
    # alphabetical display order some facets (e.g. format) are configured with.
    def facet_params(config)
      fields = filter_facets(config).values.map(&:solr_field).uniq
      fields.each_with_object({ 'facet.field': fields }) do |field, params|
        params[:"f.#{field}.facet.sort"] = "count"
        params[:"f.#{field}.facet.limit"] = CatalogResults::FACET_VALUE_LIMIT
      end
    end

    # When filters eliminate every result (often because the client guessed a facet value),
    # look up what the query matches without them so the client can choose valid filter values.
    def unfiltered_search(response, params, config, controller)
      return unless params[:f].present? && response.total.zero?

      run_search(params.except(:f).merge(rows: 0), config, controller)
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
        description: "Optional filters to narrow search results. Values must exactly match a catalog facet value, including case, " \
                     "so prefer searching without filters first and choosing values from the returned facets.",
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
      facets = filter_facets(config)
      filters.each_with_object({}) do |(key, value), mapped|
        facet = facets[key.to_s]
        mapped[facet.config_key] = [value] if facet
      end
    end
  end
end
