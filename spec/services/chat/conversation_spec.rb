# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Chat::Conversation do
  subject(:conversation) do
    described_class.new(messages: [{ role: 'user', content: 'Where is Beloved?' }],
                        completion_request_factory:, tool_runner:)
  end

  let(:record_url) { 'https://searchworks.stanford.edu/view/in00000123456' }
  let(:tool_runner) { instance_double(Chat::ToolRunner, definitions: [{ type: 'function' }]) }
  let(:requests) { [] }
  let(:completions) { [] }
  let(:completion_request_factory) do
    lambda do |**options|
      requests << options
      deltas, completion = completions.shift
      instance_double(Chat::LiteLlmCompletionRequest).tap do |request|
        allow(request).to receive(:stream_completion) do |&block|
          deltas.each(&block)
          completion
        end
      end
    end
  end
  let(:events) { [].tap { |list| conversation.run { |event, data| list << [event, data] } } }
  let(:search_result) do
    { text: 'Found 1 result', structured_content: { results: [{ id: 'in00000123456', title: 'Beloved : a novel', url: record_url }] } }
  end
  let(:availability_result) do
    { text: 'Available at Green',
      structured_content: { id: 'in00000123456', url: record_url, live_status: true,
                            availability: [{ status: 'Available', library: 'Green Library', call_number: 'PS3563 .O8749 B4 1987' }],
                            online_sources: [] } }
  end

  def completion(content: nil, tool_calls: [], finish_reason: 'stop')
    message = { 'role' => 'assistant', 'content' => content }
    message['tool_calls'] = tool_calls if tool_calls.any?
    Chat::LiteLlmCompletionRequest::Completion.new(message:, tool_calls:, finish_reason:)
  end

  def tool_call(name, arguments)
    { 'id' => "call-#{name}", 'type' => 'function', 'function' => { 'name' => name, 'arguments' => arguments.to_json } }
  end

  it 'runs tools, then streams the answer with verified sources' do
    allow(tool_runner).to receive(:call).with(name: 'catalog_search_tool', arguments: { 'query' => 'Beloved' }).and_return(search_result)
    allow(tool_runner).to receive(:call).with(name: 'get_availability', arguments: { 'id' => 'in00000123456' })
                                        .and_return(availability_result)
    completions << [[], completion(tool_calls: [tool_call('catalog_search_tool', query: 'Beloved')], finish_reason: 'tool_calls')]
    completions << [[], completion(tool_calls: [tool_call('get_availability', id: 'in00000123456')], finish_reason: 'tool_calls')]
    completions << [['It is ', 'on the shelf.'], completion(content: 'It is on the shelf.')]

    names = events.map(&:first)

    expect(names).to eq %w[status tool_call status availability tool_call delta delta sources done]
    expect(events.find { |name, _| name == 'availability' }.last).to include(id: 'in00000123456', title: 'Beloved : a novel')
    expect(events.find { |name, _| name == 'sources' }.last[:sources]).to eq(
      [{ id: 'in00000123456', title: 'Beloved : a novel', url: record_url }]
    )
    expect(requests.first[:messages].first['content']).to start_with(SearchworksMcp::INSTRUCTIONS)
    expect(requests.last[:messages].pluck('role')).to eq %w[system user assistant tool assistant tool]
  end

  it 'links bare mentions of verified titles in the final answer' do
    allow(tool_runner).to receive(:call).and_return(search_result)
    completions << [[], completion(tool_calls: [tool_call('catalog_search_tool', query: 'Beloved')], finish_reason: 'tool_calls')]
    completions << [['Try Beloved : a novel.'], completion(content: 'Try Beloved : a novel.')]

    deltas = events.select { |event| %w[delta reset].include?(event.first) }

    expect(deltas.last(2)).to eq [['reset', {}], ['delta', { content: "Try [Beloved : a novel](<#{record_url}>)." }]]
  end

  it 'asks for a final answer once the tool rounds are used up' do
    allow(Rails.configuration.x.chat).to receive(:max_tool_rounds).and_return(1)
    allow(tool_runner).to receive(:call).and_return(search_result)
    completions << [[], completion(tool_calls: [tool_call('catalog_search_tool', query: 'Beloved')], finish_reason: 'tool_calls')]
    completions << [['Here is what I found.'], completion(content: 'Here is what I found.')]

    expect(events.last).to eq ['done', {}]
    expect(requests.last[:tool_choice]).to eq 'none'
  end

  it 'reports an answer cut off at the length limit before any text' do
    completions << [[], completion(finish_reason: 'length')]

    expect(events.last).to eq ['error', { reason: 'output_length_limit',
                                          message: 'The response reached its length limit before it finished. Please retry or ask a narrower question.' }]
  end

  describe '#each_event' do
    it 'encodes events as server-sent events' do
      completions << [['Hello'], completion(content: 'Hello')]

      expect(conversation.each_event.to_a).to eq [
        "event: delta\ndata: {\"content\":\"Hello\"}\n\n",
        "event: sources\ndata: {\"sources\":[]}\n\n",
        "event: done\ndata: {}\n\n"
      ]
    end

    it 'sends an error event when the model service fails' do
      factory = ->(**) { raise Net::ReadTimeout }
      conversation = described_class.new(messages: [{ role: 'user', content: 'Hi' }], completion_request_factory: factory, tool_runner:)

      expect(conversation.each_event.to_a.last).to include('event: error', '"reason":"timeout"')
    end
  end
end
