# frozen_string_literal: true

module SearchworksMcp
  # MCP tool metadata.
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
                   "for individual articles. Results do not contain current availability. Each result includes a " \
                   "required availability_lookup; follow it before presenting that record to the user.",
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
      input_schema: ArticleSearch::INPUT_SCHEMA,
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
            maxLength: MAX_ID_LENGTH
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
            maxLength: MAX_ID_LENGTH
          }
        },
        required: ["id"],
        additionalProperties: false
      },
      output_schema: -> { Schemas.record },
      annotations: READ_ONLY_ANNOTATIONS
    }.freeze

    GET_AVAILABILITY = {
      name: "get_availability",
      description: "Retrieve availability, physical location, call numbers, request URLs, and online source links. Always call this for a single " \
                   "result or the result selected from a short catalog search result list. If the response includes request_url, present it as a " \
                   "direct link so the user can request the material. Include each item's call_number with its location so the user can find it on " \
                   "the shelf. For records with many items, such as serials, too_many_items is true and no items are listed; direct the user to url.",
      input_schema: {
        properties: {
          id: {
            type: "string",
            description: "Catalog record id returned by catalog_search_tool",
            minLength: 1, maxLength: MAX_ID_LENGTH
          }
        },
        required: ["id"],
        additionalProperties: false
      },
      output_schema: -> { Schemas.availability },
      annotations: READ_ONLY_ANNOTATIONS
    }.freeze

    ALL = [CATALOG_SEARCH, ARTICLE_SEARCH, GET_CATALOG_RECORD, GET_ARTICLE, GET_AVAILABILITY].freeze

    module_function

    # @return [Hash, nil] the tool definition with this name
    def find(name)
      ALL.find { |definition| definition[:name] == name.to_s }
    end

    def resolve_schema(schema)
      schema.is_a?(Proc) ? schema.call : schema
    end

    # Runs a tool for an MCP client or the chat assistant, returning the sanitized
    # { text:, structured_content:, error: } hash.
    #
    # @param arguments [Hash] validated tool arguments with symbol keys
    # @param controller [ActionController::Base, nil] the requesting controller, for Blacklight search state
    # @param eds_guest [Boolean] whether article tools query EDS as a guest (anonymous MCP clients always do)
    def invoke(name, arguments, controller: nil, eds_guest: true)
      result = case name.to_s
               when CATALOG_SEARCH[:name] then CatalogSearch.search(controller:, **arguments)
               when ARTICLE_SEARCH[:name] then ArticleSearch.search(guest: eds_guest, **arguments)
               when GET_CATALOG_RECORD[:name] then CatalogRecord.fetch(controller:, **arguments)
               when GET_ARTICLE[:name] then ArticleRecord.fetch(guest: eds_guest, **arguments)
               when GET_AVAILABILITY[:name] then Availability.fetch(controller:, **arguments)
               else return ToolResult.failure("Tool not found: #{name}")
               end

      result.merge(
        text: SearchworksMcp.sanitize_output(result[:text].to_s),
        structured_content: SearchworksMcp.sanitize_output(result[:structured_content])
      )
    end
  end
end
