# frozen_string_literal: true

module SearchworksMcp
  # Formats catalog responses for MCP clients.
  module CatalogResults
    extend self

    def format(response:, query:, search_field:, filters:, config:)
      results = Array(response.documents).map { |document| format_document(document) }
      facets = extract_facets(response, config)

      {
        text: result_text(response.total, query, filters, results, facets),
        structured_content: {
          query: query,
          search_field: search_field,
          filters: filters,
          total: response.total,
          results: results,
          facets: facets
        }
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
        url: "https://searchworks.stanford.edu/view/#{id}",
        library: field_value(document, ["library"]),
        call_number: field_value(document, ["callnum_display"])
      }.compact
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

      response.facet_fields.each_with_object({}) do |(field_name, facet_data), facets|
        facet_config = config.facet_fields[field_name]
        next if facet_config&.label.blank?

        values = facet_values(facet_data)
        next if values.empty?

        facets[clean_label(facet_config.label)] = { label: facet_config.label, values: values }
      end
    rescue StandardError => e
      Rails.logger.warn "Could not process facets: #{e.message}"
      {}
    end

    def facet_values(facet_data)
      if facet_data.is_a?(Array)
        facet_data.each_slice(2).first(5).filter_map do |value, count|
          { value: value, count: count } if value && count
        end
      elsif facet_data.respond_to?(:items)
        facet_data.items.first(5).map { |item| { value: item.value, count: item.hits } }
      else
        []
      end
    end

    def clean_label(label)
      label.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/^_|_$/, "")
    end

    def result_text(total, query, filters, results, facets)
      filter_text = filter_text(filters)
      return "No results found for query: #{query}#{filter_text}" if results.empty?

      "Found #{total} results#{filter_text} (showing #{results.length}):\n\n" \
        "#{formatted_results(results)}#{facet_text(facets)}"
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
        lines << "   URL: #{result[:url]}"
        lines.join("\n")
      end.join("\n\n")
    end

    def facet_text(facets)
      return "" if facets.empty?

      options = facets.map do |_key, facet|
        values = facet[:values].map { |value| "#{value[:value]} (#{value[:count]})" }.join(", ")
        "- #{facet[:label]}: #{values}"
      end
      "\n\nAvailable refinement options:\n#{options.join("\n")}"
    end
  end
end
