# frozen_string_literal: true

module SearchworksMcp
  # Formats catalog responses for MCP clients.
  module CatalogResults
    extend self

    AVAILABILITY_FOLLOW_UP_LIMIT = 5
    # Users find longer result lists easier to scan as a table
    TABLE_DISPLAY_THRESHOLD = 3
    HIGHLIGHT_FIELDS = %w[all_search vern_all_search].freeze

    # Number of values per facet requested from Solr (see CatalogSearch#facet_params)
    FACET_VALUE_LIMIT = 10

    def format(response:, query:, search_field:, filters:, config:, unfiltered_response: nil) # rubocop:disable Metrics/ParameterLists
      results = Array(response.documents).map { |document| format_document(document) }
      facets = extract_facets(response, config)
      without_filters = unfiltered_summary(unfiltered_response, config)

      {
        text: result_text(response.total, query, filters, results, facets) + unfiltered_text(without_filters),
        structured_content: {
          query: query,
          search_field: search_field,
          filters: filters,
          total: response.total,
          results: results,
          facets: facets,
          without_filters: without_filters
        }.compact
      }
    end

    private

    def format_document(document)
      id = document.id || document["id"]
      {
        id: id,
        title: field_value(document, %w[title_display title_full_display]) || "Untitled",
        author: field_value(document, %w[author_person_display author_person_full_display]),
        format: field_value(document, %w[format format_main_ssim]),
        pub_date: field_value(document, %w[pub_date pub_year_tisim]),
        url: "https://searchworks.stanford.edu/view/#{ERB::Util.url_encode(id.to_s)}",
        library: field_value(document, ["library"]),
        call_number: field_value(document, ["callnum_display"]),
        matched_text: matched_text(document).presence,
        availability_lookup: {
          tool: "get_availability",
          id: id,
          instruction: "Call get_availability with this id before presenting this record to the user."
        }
      }.compact
    end

    def matched_text(document)
      return [] unless document.respond_to?(:highlight_field) && document.response

      HIGHLIGHT_FIELDS.flat_map { |field| Array(document.highlight_field(field)) }
                      .map { |snippet| snippet.to_str.squish }
                      .compact_blank
                      .uniq
    end

    def field_value(document, field_names)
      field_names.each do |field_name|
        value = document[field_name]
        return value.first if value.is_a?(Array) && value.any?
        return value if value.is_a?(String) && value.present?
      end
      nil
    end

    def extract_facets(response, config)
      return {} unless response.respond_to?(:facet_fields)

      CatalogSearch.filter_facets(config).each_with_object({}) do |(key, facet), facets|
        values = facet_values(response.facet_fields[facet.solr_field])
        next if values.empty?

        facets[key] = { label: facet.label, values: values }
      end
    rescue StandardError => e
      Rails.logger.warn "Could not process facets: #{e.message}"
      {}
    end

    def facet_values(facet_data)
      if facet_data.is_a?(Array)
        facet_data.each_slice(2).filter_map do |value, count|
          { value: value, count: count } if value && count
        end
      elsif facet_data.respond_to?(:items)
        facet_data.items.map { |item| { value: item.value, count: item.hits } }
      else
        []
      end
    end

    def unfiltered_summary(response, config)
      return unless response

      { total: response.total, facets: extract_facets(response, config) }
    end

    def unfiltered_text(summary)
      return "" unless summary
      return "\n\nThe query also has no results without filters." if summary[:total].zero?

      "\n\nWithout filters, this query has #{summary[:total]} results. The filter values may not match how these " \
        "materials are cataloged. Search again without filters, or use a filter value from these options:" \
        "#{facet_list(summary[:facets])}"
    end

    def result_text(total, query, filters, results, facets)
      filter_text = filter_text(filters)
      return "No results found for query: #{query}#{filter_text}" if results.empty?

      "Found #{total} results#{filter_text} (showing #{results.length}):\n\n" \
        "#{formatted_results(results)}#{facet_text(facets)}#{display_hint(results)}#{availability_follow_up(results)}"
    end

    def display_hint(results)
      return "" if results.length <= TABLE_DISPLAY_THRESHOLD

      "\n\nDisplay hint: Present these results to the user as a table (e.g. title, author, format, published, " \
        "library, and link) rather than as a list."
    end

    def filter_text(filters)
      return "" if filters.blank?

      applied = filters.map { |key, value| "#{key}: #{value}" }.join(", ")
      " with filters (#{applied})"
    end

    def formatted_results(results)
      results.map.with_index(1) do |result, index|
        lines = ["#{index}. #{result[:title]}"]
        lines << "   Author: #{result[:author]}" if result[:author]
        lines << "   Format: #{result[:format]}" if result[:format]
        lines << "   Published: #{result[:pub_date]}" if result[:pub_date]
        lines << "   Library: #{result[:library]}" if result[:library]
        lines << "   Call Number: #{result[:call_number]}" if result[:call_number]
        lines << "   Matched text: #{result[:matched_text].join(' … ')}" if result[:matched_text]
        lines << "   URL: #{result[:url]}"
        lines.join("\n")
      end.join("\n\n")
    end

    def facet_text(facets)
      return "" if facets.empty?

      "\n\nAvailable refinement options:#{facet_list(facets)}"
    end

    def facet_list(facets)
      facets.map do |_key, facet|
        values = facet[:values].map { |value| "#{value[:value]} (#{value[:count]})" }.join(", ")
        "\n- #{facet[:label]}: #{values}"
      end.join
    end

    def availability_follow_up(results)
      return "" if results.empty? || results.length > AVAILABILITY_FOLLOW_UP_LIMIT

      case results.length
      when 1
        "\n\nRequired next step: Call get_availability with id #{results.first[:id]} before responding to the user."
      else
        "\n\nRequired next step: After selecting the best result, call get_availability with that result's id before " \
        "responding to the user."
      end
    end
  end
end
