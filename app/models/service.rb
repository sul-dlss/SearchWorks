# frozen_string_literal: true

# Does an HTTP request to the configured service endpoint.
class Service
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def i18n_key
    @i18n_key ||= "#{@name}_search"
  end

  def settings
    case @name
    when 'lib_guides'
      Settings.libguides
    when 'library_website_api'
      Settings.library_website
    else
      Settings.public_send(@name)
    end
  end

  def search_service_class
    "#{name.camelize}SearchService".constantize
  end

  # @param [String] query_text
  # @raises [HTTP::TimeoutError] if a timeout occurs during the search
  # @returns [Array<Hash>, NilClass] an array of search results or nil if there was an error
  def query(query_text, timeout: 30)
    benchmark format("%s #{name}", CGI.escape(query_text)) do
      http = HTTP.timeout(timeout).headers(user_agent: "#{HTTP::Request::USER_AGENT} (#{Settings.user_agent})")

      search_service_class.new(http: http).search(query_text)
    end
  rescue AbstractSearchService::NoResults, HTTP::TimeoutError => e
    logger.error(e.message)
    nil
  end

  def see_all_url_template
    settings.query_url
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
end
