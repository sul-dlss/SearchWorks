# frozen_string_literal: true

require 'mcp'

# MCP Controller - HTTP interface for Model Context Protocol functionality
class McpController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_default_response_format

  # POST /mcp
  # Handle MCP requests with the SDK's Streamable HTTP transport.
  def index
    mcp_server = create_mcp_server
    transport = MCP::Server::Transports::StreamableHTTPTransport.new(
      mcp_server,
      stateless: true,
      allowed_hosts: Settings.MCP_ALLOWED_HOSTS,
      allowed_origins: Settings.MCP_ALLOWED_ORIGINS
    )
    status, headers, body = transport.handle_request(request)

    self.status = status
    headers.each { |name, value| response.set_header(name, value) }
    self.response_body = body
  rescue StandardError => e
    SearchworksMcp.report_exception(e, context: { request_id: request.uuid })
    render json: {
      jsonrpc: "2.0",
      id: nil,
      error: {
        code: -32603,
        message: "Internal server error"
      }
    }, status: :internal_server_error
  end

  private

  def set_default_response_format
    request.format = :json unless params[:format]
  end

  def create_mcp_server
    configuration = MCP::Configuration.new(
      exception_reporter: lambda do |exception, context|
        SearchworksMcp.report_exception(exception, context: context)
      end,
      validate_tool_call_results: true
    )
    MCP::Server.new(
      name: "searchworks",
      title: "SearchWorks Stanford Library Search",
      description: "Search Stanford Libraries catalog and article metadata.",
      version: Settings.REVISION.presence || "1.0.0",
      website_url: "https://searchworks.stanford.edu",
      instructions: "Choose the search tool that matches the requested material; do not call both unless the user " \
                    "asks for both. Use catalog_search_tool for books, journals as whole publications, databases, " \
                    "media, archives, maps, and other catalog materials. Use article_search_tool for individual " \
                    "scholarly, journal, or newspaper articles. Use the corresponding get tool only when detailed " \
                    "metadata is needed for a selected result. Cite the canonical SearchWorks URL returned by tools.",
      tools: [catalog_tool, article_tool, catalog_record_tool, article_record_tool],
      capabilities: { tools: {} },
      ttl_ms: 1.hour.in_milliseconds,
      cache_scope: "public",
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

  def catalog_record_tool
    build_tool(SearchworksMcp::Tools::GET_CATALOG_RECORD) do |arguments, context|
      SearchworksMcp::CatalogRecord.fetch(controller: context&.dig(:controller), **arguments)
    end
  end

  def article_record_tool
    build_tool(SearchworksMcp::Tools::GET_ARTICLE) do |arguments, _context|
      SearchworksMcp::ArticleRecord.fetch(**arguments)
    end
  end

  def build_tool(definition, &search)
    schema = definition[:input_schema]
    Class.new(MCP::Tool).tap do |tool|
      tool.tool_name definition[:name]
      tool.description definition[:description]
      tool.input_schema(schema.is_a?(Proc) ? schema.call : schema)
      output_schema = definition[:output_schema]
      tool.output_schema(output_schema.is_a?(Proc) ? output_schema.call : output_schema) if output_schema
      tool.annotations(definition[:annotations]) if definition[:annotations]
      tool.define_singleton_method(:call) do |**arguments|
        context = arguments.delete(:server_context)
        result = search[arguments, context]
        text = SearchworksMcp.sanitize_output(result[:text].to_s)
        structured_content = SearchworksMcp.sanitize_output(result[:structured_content])
        content = [{ type: "text", text: text }]
        content << { type: "text", text: JSON.generate(structured_content) } if structured_content
        MCP::Tool::Response.new(
          content,
          structured_content: structured_content,
          error: result[:error] || false
        )
      end
    end
  end
end
