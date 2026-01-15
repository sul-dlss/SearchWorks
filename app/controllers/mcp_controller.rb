# frozen_string_literal: true

require 'mcp'

# MCP Controller - HTTP interface for Model Context Protocol functionality
# Uses the official MCP::Server#handle_json method for proper MCP compliance
class McpController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_default_response_format

  # POST /mcp
  # Handle MCP JSON-RPC requests via HTTP
  def index
    mcp_server = create_mcp_server
    response_json = mcp_server.handle_json(request.body.read)

    render json: response_json
  rescue StandardError => e
    Rails.logger.error "MCP Error: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    render json: {
      jsonrpc: "2.0",
      id: nil,
      error: {
        code: -32603,
        message: "Internal error: #{e.message}"
      }
    }, status: :internal_server_error
  end

  private

  def set_default_response_format
    request.format = :json unless params[:format]
  end

  def create_mcp_server
    # Define catalog search tool with proper class name
    catalog_tool = Class.new(MCP::Tool) do
      tool_name "catalog_search_tool"
      description "Search the Stanford library catalog for books, journals, media, and other materials. " \
                  "Returns bibliographic records with titles, authors, publication info, and availability. " \
                  "Also provides facet suggestions for refining search results (format, language, topic, etc.)."

      # Get dynamic schema from the module
      input_schema_proc = lambda {
        SearchworksMcp::CatalogSearch.build_input_schema
      }

      input_schema(input_schema_proc.call)

      def self.call(**args)
        args.delete(:server_context)
        result = SearchworksMcp::CatalogSearch.search(**args)

        MCP::Tool::Response.new(
          [{
            type: "text",
            text: result[:text]
          }],
          structured_content: result[:structured_content],
          error: result[:error] || false
        )
      end
    end

    # Define article search tool with proper class name
    article_tool = Class.new(MCP::Tool) do
      tool_name "article_search_tool"
      description "Search for scholarly articles, journal articles, and other academic publications. " \
                  "Requires EDS (EBSCO Discovery Service) to be enabled. Returns article metadata " \
                  "including titles, authors, abstracts, and full-text links when available."

      input_schema({
                     properties: {
                       query: {
                         type: "string",
                         description: "The search query to find articles"
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
                     required: ["query"]
                   })

      def self.call(**args)
        args.delete(:server_context)
        result = SearchworksMcp::ArticleSearch.search(**args)

        MCP::Tool::Response.new(
          [{
            type: "text",
            text: result[:text]
          }],
          structured_content: result[:structured_content],
          error: result[:error] || false
        )
      end
    end

    configuration = MCP::Configuration.new(protocol_version: "2025-03-26")

    # Create the MCP server
    MCP::Server.new(
      name: "searchworks",
      title: "SearchWorks Stanford Library Search",
      version: "1.0.0",
      instructions: "Use these tools to search Stanford University Libraries catalog and article databases. " \
                    "The catalog search finds books, journals, media, and other physical/digital materials. " \
                    "The article search finds scholarly articles and publications.",
      tools: [catalog_tool, article_tool],
      server_context: {
        controller: self,
        request_id: request.uuid
      },
      configuration: configuration
    )
  end
end
