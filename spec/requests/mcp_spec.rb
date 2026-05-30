# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MCP endpoint' do
  # Stub the RSolr connection so requests don't need a running Solr.
  # We stub at the RSolr client level (not the Blacklight repository level) so that
  # the SearchBuilder processor chain still runs — that's where the bug manifests.
  let(:solr_connection) { double('solr_connection') }
  let(:empty_solr_response) do
    {
      'responseHeader' => { 'status' => 0, 'params' => {} },
      'response' => { 'numFound' => 0, 'start' => 0, 'docs' => [] }
    }
  end

  before do
    allow_any_instance_of(Blacklight::Solr::Repository).to receive(:connection).and_return(solr_connection)
    allow(solr_connection).to receive(:send_and_receive).and_return(empty_solr_response)
  end

  describe 'POST /mcp' do
    def post_mcp(body)
      post '/mcp', params: body.to_json, headers: { 'Content-Type' => 'application/json' }
    end

    describe 'tools/call catalog_search_tool' do
      context 'with a plain query (no filters)' do
        it 'returns a successful result' do
          post_mcp(
            jsonrpc: '2.0', id: '1', method: 'tools/call',
            params: { name: 'catalog_search_tool', arguments: { query: 'physics' } }
          )

          expect(response).to have_http_status(:ok)
          body = JSON.parse(response.body)
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
          body = JSON.parse(response.body)
          expect(body.dig('result', 'isError')).not_to be true
          expect(body.dig('result', 'content', 0, 'text')).not_to include("controller_name")
          expect(body.dig('result', 'content', 0, 'text')).to include('No results found')
        end
      end
    end
  end
end
