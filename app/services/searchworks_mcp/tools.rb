# frozen_string_literal: true

module SearchworksMcp
  # MCP tool metadata and dispatch.
  module Tools
    READ_ONLY_ANNOTATIONS = {
      read_only_hint: true,
      destructive_hint: false,
      idempotent_hint: true,
      open_world_hint: true
    }.freeze

    CATALOG_SEARCH = {
      name: "catalog_search_tool",
      description: "Search the Stanford library catalog for books, journals as cataloged publications, databases, " \
                   "media, archival collections, maps, and other library materials. Use article_search_tool instead " \
                   "when the user wants individual scholarly or journal articles. Returns bibliographic records, " \
                   "availability, canonical SearchWorks URLs, and facet suggestions.",
      input_schema: -> { CatalogSearch.build_input_schema },
      output_schema: -> { Schemas.catalog_search },
      annotations: READ_ONLY_ANNOTATIONS
    }.freeze

    ARTICLE_SEARCH = {
      name: "article_search_tool",
      description: "Search EDS for individual scholarly articles, journal articles, newspaper articles, and other " \
                   "academic publications. Use catalog_search_tool instead for books, journals as whole publications, " \
                   "databases, media, archival collections, maps, and other catalog materials. Returns article " \
                   "metadata and canonical SearchWorks URLs; access to full text may require Stanford authentication.",
      input_schema: {
        properties: {
          query: {
            type: "string",
            description: "The search query to find articles",
            minLength: 1,
            maxLength: ArticleSearch::MAX_QUERY_LENGTH
          },
          search_field: {
            type: "string",
            description: "The field to search in",
            enum: %w[all_fields title author subject],
            default: "all_fields"
          },
          rows: {
            type: "integer",
            description: "Number of results to return (max 20)",
            minimum: 1,
            maximum: 20,
            default: 10
          }
        },
        required: ["query"],
        additionalProperties: false
      },
      output_schema: -> { Schemas.article_search },
      annotations: READ_ONLY_ANNOTATIONS
    }.freeze

    GET_CATALOG_RECORD = {
      name: "get_catalog_record",
      description: "Retrieve detailed bibliographic metadata for one catalog result. Call this with an id returned by " \
                   "catalog_search_tool. This retrieves catalog metadata, not the full text of the cataloged work.",
      input_schema: {
        properties: {
          id: {
            type: "string",
            description: "Catalog record id returned by catalog_search_tool",
            minLength: 1,
            maxLength: CatalogRecord::MAX_ID_LENGTH
          }
        },
        required: ["id"],
        additionalProperties: false
      },
      output_schema: -> { Schemas.record },
      annotations: READ_ONLY_ANNOTATIONS
    }.freeze

    GET_ARTICLE = {
      name: "get_article",
      description: "Retrieve detailed metadata and an available abstract for one article result. Call this with an id " \
                   "returned by article_search_tool. This does not return licensed article full text.",
      input_schema: {
        properties: {
          id: {
            type: "string",
            description: "Article id returned by article_search_tool",
            minLength: 1,
            maxLength: ArticleRecord::MAX_ID_LENGTH
          }
        },
        required: ["id"],
        additionalProperties: false
      },
      output_schema: -> { Schemas.record },
      annotations: READ_ONLY_ANNOTATIONS
    }.freeze
    ALL_TOOLS = [CATALOG_SEARCH, ARTICLE_SEARCH, GET_CATALOG_RECORD, GET_ARTICLE].freeze

    def self.list_tools
      ALL_TOOLS.map do |tool|
        schema = tool[:input_schema]
        output_schema = tool[:output_schema]
        {
          name: tool[:name],
          description: tool[:description],
          inputSchema: schema.is_a?(Proc) ? schema.call : schema,
          outputSchema: output_schema.is_a?(Proc) ? output_schema.call : output_schema,
          annotations: annotation_schema(tool[:annotations])
        }.compact
      end
    end

    def self.call_tool(name, arguments = {})
      case name
      when "catalog_search_tool"
        CatalogSearch.search(**arguments.symbolize_keys)
      when "article_search_tool"
        ArticleSearch.search(**arguments.symbolize_keys)
      when "get_catalog_record"
        CatalogRecord.fetch(**arguments.symbolize_keys)
      when "get_article"
        ArticleRecord.fetch(**arguments.symbolize_keys)
      else
        { text: "Unknown tool: #{name}", structured_content: { error: "Unknown tool" }, error: true }
      end
    end

    def self.annotation_schema(annotations)
      return unless annotations

      {
        readOnlyHint: annotations[:read_only_hint],
        destructiveHint: annotations[:destructive_hint],
        idempotentHint: annotations[:idempotent_hint],
        openWorldHint: annotations[:open_world_hint]
      }
    end
  end
end
