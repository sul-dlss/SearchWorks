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
  end

  def initialize(options = {})
    @query_url = options[:query_url]
    @response_class = options[:response_class].to_s.constantize
    @http = options.fetch(:http, HTTP)
  end

  # @param [String] query
  def search(query)
    url = format(@query_url, q: CGI.escape(query), max: Settings.MAX_RESULTS)

    response = @http.get(url)

    unless response.status.success? && response.body.present?
      raise NoResults, "Search response failed: #{url} status: #{response.status} body #{response.body}"
    end

    @response_class.new(response.body.to_s)
  end
end
