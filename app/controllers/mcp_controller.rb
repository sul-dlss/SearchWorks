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
    Honeybadger.notify(e)
  end

  private

  def set_default_response_format
    request.format = :json unless params[:format]
  end

  def create_mcp_server
    configuration = MCP::Configuration.new(protocol_version: "2025-03-26")
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

  def catalog_tool
    build_tool(SearchworksMcp::Tools::CATALOG_SEARCH) do |arguments, context|
      SearchworksMcp::CatalogSearch.search(controller: context&.dig(:controller), **arguments)
    end
  end

  def article_tool
    build_tool(SearchworksMcp::Tools::ARTICLE_SEARCH) do |arguments, _context|
      SearchworksMcp::ArticleSearch.search(**arguments)
    end
  end

  def build_tool(definition, &search)
    schema = definition[:input_schema]
    Class.new(MCP::Tool).tap do |tool|
      tool.tool_name definition[:name]
      tool.description definition[:description]
      tool.input_schema(schema.is_a?(Proc) ? schema.call : schema)
      tool.define_singleton_method(:call) do |**arguments|
        context = arguments.delete(:server_context)
        result = search[arguments, context]
        MCP::Tool::Response.new(
          [{ type: "text", text: result[:text] }],
          structured_content: result[:structured_content],
          error: result[:error] || false
        )
      end
    end
  end
end
