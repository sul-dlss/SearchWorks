# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Chat::ToolRunner do
  subject(:runner) { described_class.new(controller:, eds_guest: false) }

  let(:controller) { nil }

  describe '#definitions' do
    it 'offers every SearchWorks MCP tool as an OpenAI-compatible function' do
      expect(runner.definitions.map { |definition| definition.dig(:function, :name) }).to eq(
        %w[catalog_search_tool article_search_tool get_catalog_record get_article get_availability]
      )
    end

    it 'sends only the JSON Schema subset LiteLLM providers accept' do
      parameters = runner.definitions.find { |definition| definition.dig(:function, :name) == 'get_availability' }
                         .dig(:function, :parameters)

      expect(parameters).to include(type: 'object', required: ['id'])
      expect(parameters).not_to have_key(:additionalProperties)
      expect(parameters.dig(:properties, :id)).to include(type: 'string', minLength: 1)
    end
  end

  describe '#call' do
    it 'validates arguments against the MCP input schema' do
      result = runner.call(name: 'get_availability', arguments: {})

      expect(result).to include(error: true)
      expect(result[:text]).to include('missing required properties: id')
    end

    it 'rejects unknown tools' do
      expect(runner.call(name: 'delete_everything', arguments: {})).to include(error: true, text: 'Tool not found: delete_everything')
    end

    it 'runs the tool with the controller and EDS access the chat request established' do
      allow(SearchworksMcp::Tools).to receive(:invoke).and_return({ text: 'ok', structured_content: { id: '1', title: 'A title' } })

      runner.call(name: 'get_article', arguments: { 'id' => 'eds__123' })

      expect(SearchworksMcp::Tools).to have_received(:invoke)
        .with('get_article', { id: 'eds__123' }, controller: nil, eds_guest: false)
    end

    it 'instruments the call without user identity' do
      allow(SearchworksMcp::Tools).to receive(:invoke)
        .and_return({ text: 'ok', structured_content: { results: [{ id: '1', title: 'A title', url: 'u' }] } })
      events = []
      callback = ->(event) { events << event }

      ActiveSupport::Notifications.subscribed(callback, /mcp_tool\z/) do
        runner.call(name: 'catalog_search_tool', arguments: { 'query' => 'frogs' })
      end

      expect(events.map(&:name)).to eq(%w[start.mcp_tool call.mcp_tool])
      expect(events.last.payload).to include(tool_name: 'catalog_search_tool', input: { 'query' => 'frogs' },
                                             results: [{ id: '1', title: 'A title' }])
    end

    it 'turns unexpected exceptions into a tool error' do
      allow(SearchworksMcp::Tools).to receive(:invoke).and_raise('boom')
      allow(SearchworksMcp).to receive(:report_exception)

      expect(runner.call(name: 'get_availability', arguments: { 'id' => '1' }))
        .to include(error: true, text: 'The tool could not complete that request.')
    end
  end
end
