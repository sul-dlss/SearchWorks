# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('lib/chat_evaluation/load')

RSpec.describe Chat::Evaluation::Runner do
  subject(:runner) do
    described_class.new(cases_path:, report_path: tmp_dir.join('report.json'), chat_client:, judge:, output: StringIO.new)
  end

  let(:tmp_dir) { Pathname(Dir.mktmpdir) }
  let(:cases_path) do
    tmp_dir.join('cases.yml').tap do |path|
      path.write(<<~YAML)
        cases:
          - id: beloved
            question: Where is Beloved?
            reference_answer: In Green Library.
            rubric: [Says Green Library]
            require_citations: true
            require_tools: [get_availability]
            forbid_tools: [article_search_tool]
      YAML
    end
  end
  let(:url) { 'https://searchworks.stanford.edu/view/1669346' }
  let(:tool_calls) { [{ name: 'catalog_search_tool' }, { name: 'get_availability' }] }
  let(:answer) { "It is in Green Library: [Beloved](#{url})." }
  let(:chat_client) { instance_double(Chat::Evaluation::LocalChatClient) }
  let(:judge) { instance_double(Chat::Evaluation::LiteLlmJudge, model: 'judge-model') }

  before do
    allow(chat_client).to receive(:ask).and_return(
      Chat::Evaluation::LocalChatClient::Result.new(answer:, sources: [{ 'title' => 'Beloved', 'url' => url }],
                                                    availability: [{ id: '1669346' }], tool_calls:, notices: [])
    )
    allow(judge).to receive(:evaluate)
      .and_return(Chat::Evaluation::LiteLlmJudge::Verdict.new(pass: true, score: 0.9, reason: 'Correct', criteria: []))
  end

  after { FileUtils.remove_entry(tmp_dir) }

  it 'passes a correct, cited answer that used the required tools and writes a report' do
    result = runner.run

    expect(result.passed).to be true
    expect(JSON.parse(tmp_dir.join('report.json').read).dig('cases', 0, 'attempts', 0, 'tools_called'))
      .to eq %w[catalog_search_tool get_availability]
  end

  context 'when a required tool was not called' do
    let(:tool_calls) { [{ name: 'catalog_search_tool' }] }

    it 'fails the case' do
      expect(runner.run.report.dig(:cases, 0, :attempts, 0, :checks)).to include(required_tools: false)
    end
  end

  context 'when a forbidden tool was called' do
    let(:tool_calls) { [{ name: 'get_availability' }, { name: 'article_search_tool' }] }

    it 'fails the case' do
      expect(runner.run.passed).to be false
    end
  end

  context 'when the answer does not link a verified record' do
    let(:answer) { 'It is in Green Library.' }

    it 'fails the case' do
      expect(runner.run.report.dig(:cases, 0, :attempts, 0, :checks)).to include(citations: false)
    end
  end
end
