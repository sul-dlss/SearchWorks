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
  class HighlightedFacetItem; end

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
    HIGHLIGHTED_FACET_FIELD = nil
    HIGHLIGHTED_FACET_CLASS = AbstractSearchService::HighlightedFacetItem
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

    # @return [Array<Hash>] where the hash is the same as Solr's response
    def facets
      raise NotImplementedError
    end

    def additional_facet_details(*)
      nil
    end

    # @param [Integer] `count` is the number of facets to return
    # @return [Array<HighlightedFacetItem>]
    def highlighted_facet_values(count = 3)
      return [] unless defined?(self.class::HIGHLIGHTED_FACET_FIELD) && defined?(self.class::QUERY_URL)

      sorted_highlighted_facet_values.take(count).map do |facet_hash|
        self.class::HIGHLIGHTED_FACET_CLASS.new(facet_hash, self.class::HIGHLIGHTED_FACET_FIELD, self.class::QUERY_URL)
      end
    end

    private

    def sorted_highlighted_facet_values
      return [] unless highlighted_facet['items'].present?

      highlighted_facet['items'].sort { |a, b| b['hits'].to_i <=> a['hits'].to_i }
    end

    def highlighted_facet
      facets.find do |facet|
        facet['name'] == self.class::HIGHLIGHTED_FACET_FIELD
      end || {}
    end
  end

  class Result
    ATTRS = %i[author title imprint description link id thumbnail breadcrumbs fulltext_link_html temporary_access_link_html].freeze
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

  ##
  # A generic model to represent a solr facet that includes the ability to merge the configured
  # query url for the bento endpoint with a given query and append a facet query param
  class HighlightedFacetItem
    def initialize(facet_hash, field_name, base_query_url)
      @facet_hash = facet_hash
      @field_name = field_name
      @base_query_url = base_query_url
    end

    def label
      facet_hash['label']
    end

    def value
      facet_hash['value']
    end

    def hits
      (facet_hash['hits'] || 0).to_i
    end

    def query_url(query_string)
      "#{format(base_query_url, q: query_string)}&#{facet_field_to_param}"
    end

    private

    attr_reader :facet_hash, :field_name, :base_query_url

    def facet_field_to_param
      { f: { field_name => [value] } }.to_query
    end
  end
end
