# frozen_string_literal: true

module SearchworksMcp
  # Article search functionality exposed through MCP.
  module ArticleSearch
    extend self

    SEARCH_FIELDS = {
      "all_fields" => "search",
      "title" => "title",
      "author" => "author",
      "subject" => "subject"
    }.freeze

    def search(query:, search_field: "all_fields", rows: 10)
      return disabled_response unless Settings.EDS_ENABLED

      response = search_service(query, search_field, rows).search_results
      results = Array(response.documents).map { |document| format_document(document) }

      {
        text: result_text(response.total, query, results),
        structured_content: {
          query: query,
          search_field: search_field,
          total: response.total,
          results: results
        }
      }
    rescue StandardError => e
      {
        text: "Error searching articles: #{e.message}",
        structured_content: { error: e.message },
        error: true
      }
    end

    private

    def disabled_response
      {
        text: "Article search is not currently enabled. EDS (EBSCO Discovery Service) must be configured.",
        structured_content: { error: "EDS not enabled" },
        error: true
      }
    end

    def search_service(query, search_field, rows)
      params = {
        q: query,
        search_field: SEARCH_FIELDS.fetch(search_field, "search"),
        rows: [rows, 20].min
      }
      eds_params = {
        guest: true,
        session_token: Eds::Session.new(guest: true, caller: "mcp-server").session_token
      }
      Eds::SearchService.new(ArticlesController.blacklight_config, params, eds_params)
    end

    def format_document(document)
      id = document.id || document["id"]
      abstract = field_value(document, ["eds_abstract"])
      {
        id: id,
        title: field_value(document, ["eds_title"]) || "Untitled",
        authors: document["eds_authors"] || [],
        source: field_value(document, ["eds_composed_title"]),
        publication_date: field_value(document, ["eds_publication_date"]),
        abstract: abstract&.truncate(500),
        subjects: document["eds_subjects"] || [],
        url: "https://searchworks.stanford.edu/articles/#{id}"
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

    def result_text(total, query, results)
      return "No articles found for query: #{query}" if results.empty?

      "Found #{total} articles (showing #{results.length}):\n\n#{formatted_results(results)}"
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
