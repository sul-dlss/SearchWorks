# frozen_string_literal: true

module SearchworksMcp
  # Formats article (EDS) responses for MCP clients.
  module ArticleResults
    extend self

    # Facets returned so clients can choose filter values, keyed by filter name.
    # Values are EDS facet ids (see the articles facet config).
    FACETS = { "source_type" => { label: "Source type", eds_id: "SourceType" } }.freeze
    FACET_VALUE_LIMIT = 10

    def format(response:, query:, search_field:, filters:, unfiltered_response: nil)
      results = Array(response.documents).map { |document| format_document(document) }
      facets = extract_facets(response)
      without_filters = unfiltered_summary(unfiltered_response)
      warnings = filter_warnings(response, filters)
      text = result_text(response.total, query, filters, results) + TextFormat.facets(facets) + unfiltered_text(without_filters)

      ToolResult.success(
        warning_text(warnings) + text,
        {
          query: query,
          search_field: search_field,
          filters: filters,
          total: response.total,
          results: results,
          facets: facets,
          without_filters: without_filters,
          warnings: warnings.presence
        }.compact
      )
    end

    private

    def unfiltered_summary(response)
      return unless response

      { total: response.total, facets: extract_facets(response) }
    end

    # EDS ignores facet filter values it doesn't recognize instead of returning no results,
    # so tell the client when the requested source type isn't one EDS knows about.
    def filter_warnings(response, filters)
      source_type = filters[:source_type]
      return [] unless source_type && response.total.positive?

      known = facet_items(response, FACETS["source_type"][:eds_id]).map(&:value)
      return [] if known.empty? || known.include?(source_type)

      ["Source type \"#{source_type}\" does not match any EDS source type and was ignored, so these results are " \
       "not filtered by source type. Search again using one of the listed source types."]
    end

    def warning_text(warnings)
      warnings.map { |warning| "Warning: #{warning}\n\n" }.join
    end

    def facet_items(response, eds_id)
      aggregations = response.respond_to?(:aggregations) ? response.aggregations : {}
      aggregations[eds_id]&.items || []
    end

    def extract_facets(response)
      FACETS.each_with_object({}) do |(key, facet), facets|
        items = facet_items(response, facet[:eds_id])
        values = items.first(FACET_VALUE_LIMIT).map { |item| { value: item.value, count: item.hits } }
        facets[key] = { label: facet[:label], values: values } if values.any?
      end
    rescue StandardError => e
      Rails.logger.warn "Could not process article facets: #{e.message}"
      {}
    end

    def format_document(document)
      id = document.id || document["id"]
      abstract = TextFormat.first_value(document, ["eds_abstract"])
      {
        id: id,
        title: TextFormat.first_value(document, ["eds_title"]) || "Untitled",
        authors: document["eds_authors"] || [],
        source: TextFormat.first_value(document, ["eds_composed_title"]),
        publication_date: TextFormat.first_value(document, ["eds_publication_date"]),
        abstract: abstract&.truncate(500),
        subjects: document["eds_subjects"] || [],
        url: Urls.article(id)
      }.compact
    end

    def result_text(total, query, filters, results)
      filter_text = filters.any? ? " with filters (#{filters.map { |key, value| "#{key}: #{value}" }.join(', ')})" : ""
      return "No articles found for query: #{query}#{filter_text}" if results.empty?

      "Found #{total} articles#{filter_text} (showing #{results.length}):\n\n#{formatted_results(results)}"
    end

    def unfiltered_text(summary)
      return "" unless summary
      return "\n\nThe query also has no results without filters." if summary[:total].zero?

      "\n\nWithout filters, this query has #{summary[:total]} articles. Search again with fewer or broader " \
        "filters, or use a source type from these options:#{TextFormat.facet_list(summary[:facets])}"
    end

    def formatted_results(results)
      results.map.with_index(1) do |result, index|
        lines = ["#{index}. #{result[:title]}"]
        lines << "   Authors: #{result[:authors].join(', ')}" if result[:authors]&.any?
        lines << "   Source: #{result[:source]}" if result[:source]
        lines << "   Published: #{result[:publication_date]}" if result[:publication_date]
        lines << "   Abstract: #{result[:abstract]}" if result[:abstract]
        lines << "   URL: #{result[:url]}"
        lines.join("\n")
      end.join("\n\n")
    end
  end
end
