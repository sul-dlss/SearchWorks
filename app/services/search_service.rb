class SearchService
  attr_reader :query

  def initialize(query)
    @query = query
  end

  def one(searcher, timeout: 30)
    benchmark "%s #{searcher}" % CGI.escape(query.to_str) do
      klass = case searcher
      when Class
        searcher
      else
        "QuickSearch::#{searcher.camelize}Searcher".constantize
      end

      client = HTTP.timeout(timeout).headers(user_agent: "#{HTTP::Request::USER_AGENT} (#{Settings.user_agent})")

      klass.new(client, query).tap { |searcher| searcher.search }
    end
  end

  BenchmarkLogger = ActiveSupport::Logger.new(Rails.root.join('log/benchmark.log'))
  BenchmarkLogger.formatter = Logger::Formatter.new

  private

  def benchmark(message)
    result = nil
    bench_result = Benchmark.realtime { result = yield }
    BenchmarkLogger.info '%s (%.1fms)' % [ message, bench_result * 1000 ]
    result
  end

  def logger
    Rails.logger
  end
end
