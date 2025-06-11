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

  class Request
    def initialize(search_terms, max_results = Settings.MAX_RESULTS)
      @search_terms = search_terms.respond_to?(:join) ? search_terms.join(' ') : search_terms
      @max_results = max_results
    end

    # @param [String] `base` is a URL that has format parameters `q` and `max`
    def url(base)
      format(base.to_s, q: CGI.escape(q), max: max)
    end

    def q
      @search_terms.to_s
    end

    def max
      @max_results.to_i
    end
  end

  ##
  # The AbstractSearchService::Response class is intended to be subclassed by various AbstractSearchService subclasses
  # Various methods or constants will need to be overriden in order for the subclassed response class to work properly
  class Response
    QUERY_URL = nil

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
  end

  class Result
    ATTRS = %i[title format icon physical author journal imprint description online_badge link id thumbnail fulltext_link_html].freeze
    attr_accessor *ATTRS

    def to_h
      h = {}
      ATTRS.each do |k|
        h[k] = send(k)
      end
      h.compact
    end
  end

  def initialize(options = {})
    @query_url = options[:query_url]
    @response_class = options[:response_class].to_s.constantize
    @http = options.fetch(:http, HTTP)
  end

  # @param [Request | String]
  def search(request_or_query)
    url = if request_or_query.respond_to?(:url)
            request_or_query.url(@query_url.to_s)
          else
            format(@query_url.to_s, q: CGI.escape(request_or_query.to_s), max: Settings.MAX_RESULTS)
          end

    response = @http.get(url.to_s)

    raise NoResults unless response.status.success? && response.body.present?

    @response_class.new(response.body.to_s)
  end
end
