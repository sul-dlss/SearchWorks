# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'yaml'

module Chat
  module Evaluation
    # Runs configured questions through the chat assistant, has an independent model judge each
    # answer, and writes an auditable JSON report.
    class Runner # rubocop:disable Metrics/ClassLength
      RETRY_DELAYS = [0.5, 1.0].freeze
      RETRYABLE_ERRORS = [EOFError, Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED,
                          Errno::ECONNRESET, Errno::EPIPE, Errno::ETIMEDOUT].freeze
      RETRYABLE_HTTP_CODES = %w[408 429 502 503 504].freeze

      HISTORY_ROLES = %w[user assistant].freeze

      RunResult = Data.define(:passed, :report_path, :report)

      def initialize( # rubocop:disable Metrics/ParameterLists
        cases_path: Rails.root.join('lib/chat_evaluation/chat_evaluations.yml'),
        case_id: nil,
        minimum_score: 0.8,
        runs: 1,
        required_pass_rate: 1.0,
        report_path: nil,
        chat_client: nil,
        judge: nil,
        output: $stdout
      )
        @cases_path = Pathname(cases_path)
        @case_id = case_id.presence
        @minimum_score = Float(minimum_score)
        @runs = Integer(runs)
        @required_pass_rate = Float(required_pass_rate)
        @report_path = report_path && Pathname(report_path)
        @chat_client = chat_client || LocalChatClient.new
        @judge = judge || LiteLlmJudge.new
        @output = output
        validate_options!
      end

      def run
        started_at = Time.current
        results = load_cases.map { |evaluation_case| evaluate_case(evaluation_case) }
        passed = results.all? { |result| result.fetch(:passed) }
        report = {
          chat_model: ENV.fetch('LITELLM_CHAT_MODEL', nil),
          evaluation_model: @judge.model,
          started_at: started_at.iso8601,
          finished_at: Time.current.iso8601,
          minimum_score: @minimum_score,
          runs_per_case: @runs,
          required_pass_rate: @required_pass_rate,
          passed:,
          cases: results
        }
        report_path = write_report(report)
        @output.puts("Chat evaluation #{passed ? 'PASSED' : 'FAILED'}; report: #{report_path}")
        RunResult.new(passed:, report_path:, report:)
      end

      private

      def validate_options!
        raise ArgumentError, 'CHAT_EVAL_RUNS must be at least 1' unless @runs.positive?
        raise ArgumentError, 'CHAT_EVAL_MIN_SCORE must be between 0 and 1' unless @minimum_score.between?(0, 1)
        return if @required_pass_rate.positive? && @required_pass_rate <= 1

        raise ArgumentError, 'CHAT_EVAL_PASS_RATE must be greater than 0 and at most 1'
      end

      def load_cases
        cases = Array(YAML.safe_load_file(@cases_path, symbolize_names: true)[:cases])
        cases.select! { |evaluation_case| evaluation_case[:id].to_s == @case_id } if @case_id
        raise ArgumentError, "No chat evaluation cases matched #{@case_id.inspect}" if cases.empty?

        cases.each { |evaluation_case| validate_case!(evaluation_case) }
      end

      def validate_case!(evaluation_case)
        %i[id question reference_answer rubric].each do |key|
          raise ArgumentError, "Chat evaluation case is missing #{key}" if evaluation_case[key].blank?
        end
        Array(evaluation_case[:history]).each do |message|
          next if HISTORY_ROLES.include?(message[:role].to_s) && message[:content].is_a?(String) && message[:content].present?

          raise ArgumentError, "Chat evaluation case #{evaluation_case[:id]} has an invalid history message"
        end
      end

      def evaluate_case(evaluation_case)
        @output.puts("Evaluating #{evaluation_case.fetch(:id)}...")
        attempts = Array.new(@runs) { |index| evaluate_attempt(evaluation_case, index + 1) }
        pass_rate = attempts.count { |attempt| attempt.fetch(:passed) }.fdiv(@runs)
        evaluation_case.merge(pass_rate:, passed: pass_rate >= @required_pass_rate, attempts:)
      end

      def evaluate_attempt(evaluation_case, attempt_number)
        started_at = monotonic_time
        chat = with_retries { @chat_client.ask(evaluation_case.fetch(:question), history: evaluation_case.fetch(:history, [])) }
        elapsed = (monotonic_time - started_at).round(3)
        verdict = with_retries do
          @judge.evaluate(question: evaluation_case.fetch(:question), reference_answer: evaluation_case.fetch(:reference_answer),
                          rubric: evaluation_case.fetch(:rubric), answer: chat.answer, sources: chat.sources)
        end
        checks = checks_for(evaluation_case, chat)
        passed = verdict.pass && verdict.score >= @minimum_score && checks.values.all?
        report_attempt(attempt_number, passed, verdict, checks, elapsed)
        {
          attempt: attempt_number,
          elapsed_seconds: elapsed,
          answer: chat.answer,
          tools_called: chat.tool_calls.pluck(:name),
          tool_calls: chat.tool_calls,
          sources: chat.sources,
          availability_ids: chat.availability.pluck(:id),
          notices: chat.notices,
          checks:,
          judge: { pass: verdict.pass, score: verdict.score, reason: verdict.reason, criteria: verdict.criteria },
          passed:
        }
      rescue StandardError => e
        @output.puts("  attempt #{attempt_number}: ERROR (#{e.class}: #{e.message})")
        { attempt: attempt_number, passed: false, error: { class: e.class.name, message: e.message } }
      end

      def checks_for(evaluation_case, chat)
        {
          citations: !evaluation_case[:require_citations] || valid_citations?(chat.answer, chat.sources),
          required_tools: missing_tools(evaluation_case, chat).empty?,
          forbidden_tools: used_forbidden_tools(evaluation_case, chat).empty?,
          complete: !chat.truncated?
        }
      end

      def report_attempt(attempt_number, passed, verdict, checks, elapsed)
        failed = checks.reject { |_check, ok| ok }.keys.map { |check| "failed #{check}" }
        @output.puts("  attempt #{attempt_number}: #{passed ? 'PASS' : 'FAIL'} (score #{format('%.2f', verdict.score)}, " \
                     "#{failed.join(', ').presence || 'all checks passed'}, #{format('%.1fs', elapsed)})")
      end

      def missing_tools(evaluation_case, chat)
        Array(evaluation_case[:require_tools]).map(&:to_s) - chat.tool_calls.pluck(:name)
      end

      def used_forbidden_tools(evaluation_case, chat)
        Array(evaluation_case[:forbid_tools]).map(&:to_s) & chat.tool_calls.pluck(:name)
      end

      def with_retries
        retries = 0
        begin
          yield
        rescue StandardError => e
          raise unless transient_error?(e) && retries < RETRY_DELAYS.length

          sleep(RETRY_DELAYS.fetch(retries))
          retries += 1
          retry
        end
      end

      def transient_error?(error)
        RETRYABLE_ERRORS.any? { |error_class| error.is_a?(error_class) } ||
          RETRYABLE_HTTP_CODES.any? { |code| error.message.match?(/\(#{code}\)/) }
      end

      def monotonic_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      # At least one Markdown link in the answer points at a record a tool returned.
      def valid_citations?(answer, sources)
        verified_urls = sources.filter_map { |source| source['url'] }
        cited_urls = answer.scan(/\[[^\]\n]+\]\((?:<([^>\n]+)>|([^)\s]+))\)/).map { |match| match.compact.first }
        verified_urls.intersect?(cited_urls)
      end

      def write_report(report)
        path = @report_path || Rails.root.join("tmp/chat_evaluations/#{Time.current.utc.strftime('%Y%m%dT%H%M%SZ')}.json")
        FileUtils.mkdir_p(path.dirname)
        path.write("#{JSON.pretty_generate(report)}\n")
        path
      end
    end
  end
end
