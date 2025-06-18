# frozen_string_literal: true

##
# Usage
#
# response = <YOUR_ENGINE>SearchService.new.search('my query')
# response.results # Array of Hash with :title, :description, :url for each hit
# response.facets # Array of Solr Hash for facets
# response.body # raw JSON
#
# You can also use the Request class if needed for the .search method parameter:
#
# request = <YOUR_ENGINE>SearchService::Request.new('my query', other, local, options)
# response = <YOUR_ENGINE>SearchService.new.search(request)
#
class AbstractSearchService
  class NoResults < StandardError; end

  ##
  # The AbstractSearchService::Response class is intended to be subclassed by various AbstractSearchService subclasses
  # Various methods or constants will need to be overriden in order for the subclassed response class to work properly
  class Response
    attr_reader :body

    # @param [String] `body` is the HTTP response body
    def initialize(body)
      @body = body
    end

    # @return [Integer] total number of hits
    def total
      raise NotImplementedError
    end

    # @return [Array<Result>] where the hash has `:title`, `:description`, and `:url`
    def results
      raise NotImplementedError
    end

    private

    def json
      @json ||= JSON.parse(@body)
    end
  end

  def initialize(http: nil, timeout: 30)
    @http = http || HTTP.timeout(timeout).headers(user_agent: "#{HTTP::Request::USER_AGENT} (#{Settings.user_agent})")
  end

  # @param [String] query
  def search(query)
    response = benchmark format("%s #{benchmark_name}", CGI.escape(query)) do
      @http.get(url(query))
    end

    unless response.status.success? && response.body.present?
      raise NoResults, "Search response failed: #{url(query)} status: #{response.status} body #{response.body}"
    end

    @response_class.new(response.body.to_s)
  end

  def url(query)
    format(@query_url, q: CGI.escape(query), max: Settings.MAX_RESULTS)
  end

  BenchmarkLogger = ActiveSupport::Logger.new(Rails.root.join('log/benchmark.log'))
  BenchmarkLogger.formatter = Logger::Formatter.new

  private

  delegate :logger, to: :Rails

  def benchmark(message)
    result = nil
    bench_result = Benchmark.realtime { result = yield }
    BenchmarkLogger.info format('%<message>s (%<time>.1fms)', message:, time: bench_result * 1000)
    result
  end

  def benchmark_name
    self.class.name.demodulize.underscore.sub('search_service', '')
  end
end
