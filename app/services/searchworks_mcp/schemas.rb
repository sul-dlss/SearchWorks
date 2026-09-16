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

    def self.availability
      {
        properties: {
          id: { type: "string" },
          url: { type: "string" },
          availability: {
            type: "array",
            items: {
              type: "object",
              properties: {
                item_id: { type: %w[string null] },
                due_date: { type: %w[string null] },
                status: { type: %w[string null] },
                is_available: { type: %w[boolean null] },
                is_requestable_status: { type: %w[boolean null] }
              }
            }
          }
        },
        required: %w[id url availability]
      }
    end
  end
end
