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
    transport = SearchworksMcp::StreamableHttpTransport.new(
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
      website_url: SearchworksMcp::Urls::BASE_URL,
      instructions: SearchworksMcp::INSTRUCTIONS,
      tools: SearchworksMcp::Tools::ALL.map { |definition| build_tool(definition) },
      prompts: [SearchworksMcp::Prompts::FIND_ITEM],
      capabilities: { tools: {}, prompts: {} },
      ttl_ms: 1.hour.in_milliseconds,
      cache_scope: "public",
      server_context: {
        controller: self,
        request_id: request.uuid
      },
      configuration: configuration
    )
  end

  def build_tool(definition)
    Class.new(MCP::Tool).tap do |tool|
      tool.tool_name definition[:name]
      tool.description definition[:description]
      tool.input_schema(SearchworksMcp::Tools.resolve_schema(definition[:input_schema]))
      tool.output_schema(SearchworksMcp::Tools.resolve_schema(definition[:output_schema])) if definition[:output_schema]
      tool.annotations(definition[:annotations]) if definition[:annotations]
      tool.define_singleton_method(:call) do |**arguments|
        context = arguments.delete(:server_context)
        result = SearchworksMcp::Tools.invoke(definition[:name], arguments, controller: context&.dig(:controller))
        content = [{ type: "text", text: result[:text] }]
        content << { type: "text", text: JSON.generate(result[:structured_content]) } if result[:structured_content]
        MCP::Tool::Response.new(
          content,
          structured_content: result[:structured_content],
          error: result[:error] || false
        )
      end
    end
  end
end
