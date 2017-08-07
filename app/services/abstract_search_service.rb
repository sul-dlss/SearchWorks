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
    def initialize(search_terms, max_results = 10)
      @search_terms = search_terms.respond_to?(:join) ? search_terms.join(' ') : search_terms
      @max_results = max_results
    end

    # @param [String] `base` is a URL that has format parameters `q` and `max`
    def url(base)
      base.to_s % { q: URI.escape(q), max: max }
    end

    def q
      @search_terms.to_s
    end

    def max
      @max_results.to_i
    end
  end

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

    # @return [Array<Hash>] where the hash is the same as Solr's response
    def facets
      raise NotImplementedError
    end
  end

  class Result
    attr_accessor :title, :description, :link, :id, :thumbnail
  end

  def initialize(options = {})
    @query_url = options[:query_url]
    @response_class = options[:response_class].to_s.constantize
  end

  # @param [Request | String]
  def search(request_or_query)
    url = if request_or_query.respond_to?(:url)
            request_or_query.url(@query_url.to_s)
          else
            @query_url.to_s % { q: URI.escape(request_or_query.to_s), max: 10 }
          end

    response = Faraday.get url.to_s
    raise NoResults unless response.success? && response.body.present?

    @response_class.new(response.body)
  end
end
