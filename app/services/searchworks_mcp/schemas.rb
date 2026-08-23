# frozen_string_literal: true

module SearchworksMcp
  # JSON output schemas for MCP tool responses.
  module Schemas
    SEARCH_RESULT = {
      type: "object",
      properties: {
        id: { type: "string" },
        title: { type: "string" },
        url: { type: "string" }
      },
      required: %w[id title url]
    }.freeze

    def self.catalog_search
      {
        properties: {
          query: { type: "string" },
          search_field: { type: "string" },
          filters: { type: "object" },
          total: { type: "integer" },
          results: { type: "array", items: SEARCH_RESULT },
          facets: { type: "object" }
        },
        required: %w[query search_field filters total results facets]
      }
    end

    def self.article_search
      {
        properties: {
          query: { type: "string" },
          search_field: { type: "string" },
          total: { type: "integer" },
          results: { type: "array", items: SEARCH_RESULT }
        },
        required: %w[query search_field total results]
      }
    end

    def self.record
      {
        properties: {
          id: { type: "string" },
          title: { type: "string" },
          url: { type: "string" },
          metadata: { type: "object" }
        },
        required: %w[id title url metadata]
      }
    end
  end
end
