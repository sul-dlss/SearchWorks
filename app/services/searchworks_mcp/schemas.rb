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

    AVAILABILITY_LOOKUP = {
      type: "object",
      description: "Required follow-up for current availability, physical location, and request links",
      properties: {
        tool: { type: "string" },
        id: { type: "string" },
        instruction: { type: "string" }
      },
      required: %w[tool id instruction]
    }.freeze

    CATALOG_SEARCH_RESULT = {
      type: "object",
      properties: SEARCH_RESULT[:properties].merge(availability_lookup: AVAILABILITY_LOOKUP),
      required: SEARCH_RESULT[:required] + %w[availability_lookup]
    }.freeze

    AVAILABILITY_ITEM = {
      type: "object",
      properties: {
        item_id: { type: %w[string null] },
        due_date: { type: %w[string null] },
        status: { type: %w[string null] },
        is_available: { type: %w[boolean null] },
        is_requestable_status: { type: %w[boolean null] },
        library: { type: "string" },
        library_code: { type: "string" },
        location: { type: "string" },
        location_code: { type: "string" },
        request_url: { type: "string", description: "Direct request link, when the item is requestable" }
      }
    }.freeze

    ONLINE_SOURCE = {
      type: "object",
      properties: {
        url: { type: "string" },
        label: { type: "string" },
        stanford_only: { type: "boolean" }
      },
      required: %w[url label stanford_only]
    }.freeze

    def self.catalog_search
      {
        properties: {
          query: { type: "string" },
          search_field: { type: "string" },
          filters: { type: "object" },
          total: { type: "integer" },
          results: { type: "array", items: CATALOG_SEARCH_RESULT },
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
          availability: { type: "array", items: AVAILABILITY_ITEM },
          online_sources: { type: "array", items: ONLINE_SOURCE }
        },
        required: %w[id url availability online_sources]
      }
    end
  end
end
