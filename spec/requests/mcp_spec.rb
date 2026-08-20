# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MCP endpoint' do
  # Stub the RSolr connection so requests don't need a running Solr.
  # We stub at the RSolr client level (not the Blacklight repository level) so that
  # the SearchBuilder processor chain still runs — that's where the bug manifests.
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

  describe 'POST /mcp' do
    def post_mcp(body)
      post '/mcp', params: body.to_json, headers: { 'Content-Type' => 'application/json' }
    end

    describe 'tools/list' do
      it 'advertises distinct read-only catalog and article tools with output schemas' do
        post_mcp(jsonrpc: '2.0', id: '1', method: 'tools/list', params: {})

        expect(response).to have_http_status(:ok)
        tools = response.parsed_body.dig('result', 'tools').index_by { |tool| tool['name'] }
        expect(tools.keys).to contain_exactly(
          'catalog_search_tool', 'article_search_tool', 'get_catalog_record', 'get_article'
        )
        expect(tools.values).to all(include('annotations' => include('readOnlyHint' => true)))
        expect(tools.values).to all(include('outputSchema' => include('type' => 'object')))
        expect(tools['catalog_search_tool']['description']).to include('Use article_search_tool instead')
        expect(tools['article_search_tool']['description']).to include('Use catalog_search_tool instead')
      end
    end

    describe 'tools/call catalog_search_tool' do
      context 'with a plain query (no filters)' do
        it 'returns a successful result' do
          post_mcp(
            jsonrpc: '2.0', id: '1', method: 'tools/call',
            params: { name: 'catalog_search_tool', arguments: { query: 'physics' } }
          )

          expect(response).to have_http_status(:ok)
          body = response.parsed_body
          expect(body.dig('result', 'isError')).not_to be true
          expect(body.dig('result', 'content', 0, 'text')).to include('No results found')
        end
      end

      context 'with filters applied' do
        it 'returns a successful result without raising a controller_name error' do
          post_mcp(
            jsonrpc: '2.0', id: '1', method: 'tools/call',
            params: {
              name: 'catalog_search_tool',
              arguments: { query: 'physics', filters: { format: 'Book' } }
            }
          )

          expect(response).to have_http_status(:ok)
          body = response.parsed_body
          expect(body.dig('result', 'isError')).not_to be true
          expect(body.dig('result', 'content', 0, 'text')).not_to include("controller_name")
          expect(body.dig('result', 'content', 0, 'text')).to include('No results found')
        end
      end
    end

    describe 'tools/call get_catalog_record' do
      it 'returns detailed catalog metadata from the selected result' do
        allow(SearchworksMcp::CatalogRecord).to receive(:fetch).and_return(
          text: "A catalog record\nURL: https://searchworks.stanford.edu/view/123",
          structured_content: {
            id: '123', title: 'A catalog record', url: 'https://searchworks.stanford.edu/view/123',
            metadata: { authors: ['An Author'] }
          }
        )

        post_mcp(
          jsonrpc: '2.0', id: '1', method: 'tools/call',
          params: { name: 'get_catalog_record', arguments: { id: '123' } }
        )

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.dig('result', 'structuredContent')).to include(
          'id' => '123', 'url' => 'https://searchworks.stanford.edu/view/123'
        )
      end
    end
  end
end
