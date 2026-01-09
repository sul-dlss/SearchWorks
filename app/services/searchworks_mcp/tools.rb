# frozen_string_literal: true

module SearchworksMcp
  # MCP tool metadata and dispatch.
  module Tools
    CATALOG_SEARCH = {
      name: "catalog_search_tool",
      description: "Search the Stanford library catalog for books, journals, media, and other materials. " \
                   "Returns bibliographic records with titles, authors, publication info, and availability. " \
                   "Also provides facet suggestions for refining search results (format, language, topic, etc.).",
      input_schema: -> { CatalogSearch.build_input_schema }
    }.freeze

    ARTICLE_SEARCH = {
      name: "article_search_tool",
      description: "Search for scholarly articles, journal articles, and other academic publications. " \
                   "Requires EDS (EBSCO Discovery Service) to be enabled. Returns article metadata " \
                   "including titles, authors, abstracts, and full-text links when available.",
      input_schema: {
        properties: {
          query: { type: "string", description: "The search query to find articles" },
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
        required: ["query"]
      }
    }.freeze
    ALL_TOOLS = [CATALOG_SEARCH, ARTICLE_SEARCH].freeze

    def self.list_tools
      ALL_TOOLS.map do |tool|
        schema = tool[:input_schema]
        { name: tool[:name], description: tool[:description], inputSchema: schema.is_a?(Proc) ? schema.call : schema }
      end
    end

    def self.call_tool(name, arguments = {})
      case name
      when "catalog_search_tool"
        CatalogSearch.search(**arguments.symbolize_keys)
      when "article_search_tool"
        ArticleSearch.search(**arguments.symbolize_keys)
      else
        { text: "Unknown tool: #{name}", structured_content: { error: "Unknown tool" }, error: true }
      end
    end
  end
end
