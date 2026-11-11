# frozen_string_literal: true

namespace :chat do
  desc 'Evaluate the chat assistant in-process with an independent LiteLLM judge model'
  task evaluate: :environment do
    require Rails.root.join('lib/chat_evaluation/load')

    runner = Chat::Evaluation::Runner.new(
      cases_path: ENV.fetch('CHAT_EVAL_CASES', Rails.root.join('lib/chat_evaluation/chat_evaluations.yml')),
      case_id: ENV.fetch('CHAT_EVAL_CASE', nil),
      minimum_score: ENV.fetch('CHAT_EVAL_MIN_SCORE', 0.8),
      runs: ENV.fetch('CHAT_EVAL_RUNS', 1),
      required_pass_rate: ENV.fetch('CHAT_EVAL_PASS_RATE', 1.0),
      report_path: ENV.fetch('CHAT_EVAL_REPORT', nil)
    )
    abort 'One or more chat evaluations failed' unless runner.run.passed
  end
end
