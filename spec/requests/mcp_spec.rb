# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MCP endpoint' do
  let(:mcp_protocol_version) { '2026-07-28' }

  # Stub the RSolr connection so requests don't need a running Solr. Keeping
  # SearchBuilder in the call path exercises its controller-dependent processors.
  let(:solr_connection) { instance_double(RSolr::Client) }
  let(:empty_solr_response) do
    {
      'responseHeader' => { 'status' => 0, 'params' => {} },
      'response' => { 'numFound' => 0, 'start' => 0, 'docs' => [] }
    }
  end

  before do
    allow(RSolr).to receive(:connect).and_return(solr_connection)
    allow(solr_connection).to receive(:send_and_receive).and_return(empty_solr_response)
  end

  def post_mcp(body, protocol_version: mcp_protocol_version, include_meta: true, routing_headers: true, headers: {})
    request_body = body.deep_dup
    if include_meta && request_body.is_a?(Hash)
      request_body[:params] ||= {}
      request_body[:params][:_meta] ||= {
        'io.modelcontextprotocol/protocolVersion': protocol_version,
        'io.modelcontextprotocol/clientInfo': { name: 'SearchWorks specs', version: '1.0' },
        'io.modelcontextprotocol/clientCapabilities': {}
      }
    end

    request_headers = {
      'Content-Type' => 'application/json',
      'MCP-Protocol-Version' => protocol_version
    }
    request_headers['Accept'] = 'application/json, text/event-stream' unless headers.key?('Accept')
    if routing_headers && request_body.is_a?(Hash)
      request_headers['Mcp-Method'] = request_body[:method]
      name = request_body.dig(:params, :name) || request_body.dig(:params, :uri)
      request_headers['Mcp-Name'] = name if name
    end

    post '/mcp', params: request_body.to_json, headers: request_headers.merge(headers)
  end

  describe 'POST /mcp' do
    describe 'server/discover' do
      it 'advertises the modern protocol, server identity, capabilities, and public cache metadata' do
        post_mcp({ jsonrpc: '2.0', id: 'discover', method: 'server/discover', params: {} })

        expect(response).to have_http_status(:ok)
        result = response.parsed_body.fetch('result')
        expect(result).to include(
          'resultType' => 'complete',
          'supportedVersions' => [mcp_protocol_version],
          'capabilities' => { 'tools' => {} },
          'ttlMs' => 3_600_000,
          'cacheScope' => 'public'
        )
        expect(result.dig('_meta', 'io.modelcontextprotocol/serverInfo')).to include(
          'name' => 'searchworks',
          'title' => 'SearchWorks Stanford Library Search',
          'websiteUrl' => 'https://searchworks.stanford.edu'
        )
      end
    end

    describe 'tools/list' do
      it 'returns deterministically ordered read-only tools with schemas and cache metadata' do
        request = { jsonrpc: '2.0', id: 'list', method: 'tools/list', params: {} }

        post_mcp(request)
        first_result = response.parsed_body.fetch('result')
        post_mcp(request.merge(id: 'list-again'))
        second_result = response.parsed_body.fetch('result')

        expect(first_result).to include(
          'resultType' => 'complete',
          'ttlMs' => 3_600_000,
          'cacheScope' => 'public'
        )
        expect(first_result.fetch('tools')).to eq(second_result.fetch('tools'))
        tools = first_result.fetch('tools').index_by { |tool| tool.fetch('name') }
        expect(tools.keys).to eq(
          %w[catalog_search_tool article_search_tool get_catalog_record get_article]
        )
        expect(tools.values).to all(include('annotations' => include('readOnlyHint' => true)))
        expect(tools.values).to all(include('outputSchema' => include('type' => 'object')))
        expect(tools.values).to all(include('inputSchema' => include('additionalProperties' => false)))
      end
    end

    describe 'tools/call catalog_search_tool' do
      it 'returns structured content and a serialized JSON text fallback' do
        post_mcp(
          {
            jsonrpc: '2.0', id: 'search', method: 'tools/call',
            params: { name: 'catalog_search_tool', arguments: { query: 'physics', filters: { format: 'Book' } } }
          }
        )

        expect(response).to have_http_status(:ok)
        result = response.parsed_body.fetch('result')
        expect(result).to include('resultType' => 'complete', 'isError' => false)
        expect(result.dig('content', 0, 'text')).to include('No results found')
        expect(JSON.parse(result.dig('content', 1, 'text'))).to eq(result.fetch('structuredContent'))
        expect(result.fetch('structuredContent')).to include(
          'query' => 'physics', 'filters' => { 'format' => 'Book' }, 'results' => []
        )
      end

      it 'reports invalid arguments as a model-visible tool error' do
        post_mcp(
          {
            jsonrpc: '2.0', id: 'invalid-search', method: 'tools/call',
            params: { name: 'catalog_search_tool', arguments: { query: '', unexpected: true } }
          }
        )

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.fetch('result')).to include(
          'resultType' => 'complete',
          'isError' => true
        )
      end
    end

    describe 'tools/call get_catalog_record' do
      it 'validates, sanitizes, and returns selected record metadata' do
        allow(SearchworksMcp::CatalogRecord).to receive(:fetch).and_return(
          text: "<b>A catalog record</b>\u0000\nURL: https://searchworks.stanford.edu/view/123",
          structured_content: {
            id: '123', title: '<b>A catalog record</b>', url: 'https://searchworks.stanford.edu/view/123',
            metadata: { authors: ["An Author\u0000"] }
          }
        )

        post_mcp(
          {
            jsonrpc: '2.0', id: 'record', method: 'tools/call',
            params: { name: 'get_catalog_record', arguments: { id: '123' } }
          }
        )

        expect(response).to have_http_status(:ok)
        result = response.parsed_body.fetch('result')
        expect(result).to include('resultType' => 'complete', 'isError' => false)
        expect(result.dig('structuredContent', 'title')).to eq('A catalog record')
        expect(result.dig('structuredContent', 'metadata', 'authors')).to eq(['An Author'])
        expect(result.dig('content', 0, 'text')).not_to include('<b>', "\u0000")
      end

      it 'does not expose backend exception details' do
        search_service = instance_double(Blacklight::SearchService)
        allow(search_service).to receive(:fetch).and_raise(StandardError, 'private Solr hostname')
        allow(SearchworksMcp::CatalogRecord).to receive(:search_service).and_return(search_service)
        allow(SearchworksMcp).to receive(:report_exception)

        post_mcp(
          {
            jsonrpc: '2.0', id: 'failed-record', method: 'tools/call',
            params: { name: 'get_catalog_record', arguments: { id: '123' } }
          }
        )

        expect(response).to have_http_status(:ok)
        result = response.parsed_body.fetch('result')
        expect(result).to include('resultType' => 'complete', 'isError' => true)
        expect(result.to_json).to include('Catalog record retrieval is temporarily unavailable')
        expect(result.to_json).not_to include('private Solr hostname')
      end

      it 'turns output-schema violations into protocol errors' do
        allow(SearchworksMcp::CatalogRecord).to receive(:fetch).and_return(
          text: 'Invalid record', structured_content: { id: '123' }
        )
        allow(SearchworksMcp).to receive(:report_exception)

        post_mcp(
          {
            jsonrpc: '2.0', id: 'bad-output', method: 'tools/call',
            params: { name: 'get_catalog_record', arguments: { id: '123' } }
          }
        )

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.fetch('error')).to include('code' => -32_603)
      end
    end

    describe 'transport validation' do
      it 'rejects requests missing the per-request metadata envelope' do
        post_mcp(
          { jsonrpc: '2.0', id: 'no-meta', method: 'tools/list', params: {} },
          include_meta: false
        )

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body.fetch('error')).to include('code' => -32_602)
      end

      it 'rejects missing routing headers' do
        post_mcp(
          { jsonrpc: '2.0', id: 'no-routing', method: 'tools/list', params: {} },
          routing_headers: false
        )

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body.fetch('error')).to include('code' => -32_020)
      end

      it 'rejects a routing header that disagrees with the body' do
        post_mcp(
          { jsonrpc: '2.0', id: 'mismatch', method: 'tools/list', params: {} },
          headers: { 'Mcp-Method' => 'tools/call' }
        )

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body.fetch('error')).to include('code' => -32_020)
      end

      it 'returns supported versions for an unsupported protocol version' do
        post_mcp(
          { jsonrpc: '2.0', id: 'future', method: 'tools/list', params: {} },
          protocol_version: '2099-01-01'
        )

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body.fetch('error')).to include(
          'code' => -32_022,
          'data' => { 'supported' => [mcp_protocol_version], 'requested' => '2099-01-01' }
        )
      end

      it 'returns HTTP 404 for an unknown method' do
        post_mcp({ jsonrpc: '2.0', id: 'unknown', method: 'unknown/method', params: {} })

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body.fetch('error')).to include('code' => -32_601)
      end

      it 'acknowledges notifications with an empty HTTP 202 response' do
        post_mcp({ jsonrpc: '2.0', method: 'notifications/example', params: {} })

        expect(response).to have_http_status(:accepted)
        expect(response.body).to be_empty
      end

      it 'rejects disallowed browser origins' do
        post_mcp(
          { jsonrpc: '2.0', id: 'origin', method: 'tools/list', params: {} },
          headers: { 'Origin' => 'https://evil.example' }
        )

        expect(response).to have_http_status(:forbidden)
      end

      it 'rejects JSON-RPC batches and null request ids' do
        post_mcp(
          [{ jsonrpc: '2.0', id: 'batch', method: 'tools/list', params: {} }],
          headers: { 'Mcp-Method' => 'tools/list' }
        )
        expect(response).to have_http_status(:bad_request)

        post_mcp({ jsonrpc: '2.0', id: nil, method: 'tools/list', params: {} })
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body.fetch('error')).to include('code' => -32_600)
      end

      it 'requires clients to accept JSON and event streams' do
        post_mcp(
          { jsonrpc: '2.0', id: 'accept', method: 'tools/list', params: {} },
          headers: { 'Accept' => 'text/plain' }
        )

        expect(response).to have_http_status(:not_acceptable)
      end
    end
  end

  describe 'unsupported HTTP methods' do
    it 'returns method not allowed instead of exposing a legacy GET stream' do
      get '/mcp', headers: { 'MCP-Protocol-Version' => mcp_protocol_version }

      expect(response).to have_http_status(:method_not_allowed)
    end
  end
end
