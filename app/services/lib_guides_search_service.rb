# frozen_string_literal: true

# Uses the LibGuides API to search
class LibGuidesSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= query_url
    options[:response_class] ||= Response
    super
  end

  def query_url
    [
      Settings.LIBGUIDES.API_URL.to_s,
      '?',
      {
        site_id: Settings.LIBGUIDES.SITE_ID,
        key: Settings.LIBGUIDES.KEY,
        status: 1,
        sort_by: 'relevance',
      }.to_query,
      '&search_terms=%{q}'
    ].join()
  end

  class Response < AbstractSearchService::Response
    def results
      json.first(num_results).collect do |doc|
        result = AbstractSearchService::Result.new
        result.title = doc['name']
        result.link = doc['url']
        result.id = doc['slug_id']
        result
      end
    end

    def num_results
      Settings.LIBGUIDES.NUM_RESULTS_SHOWN
    end

    def facets
      []
    end

    # The guides api will only return 100 results
    # If there are more than 100 results there is no way of knowing the correct number
    # Instead of displaying a correct number we don't display the number if the results == 100
    # Otherwise we have a correct length and can display the number of results.
    def total
      json.length == 100 ? '100+' : json.length
    end

    private

    def json
      @json ||= JSON.parse(@body)
    end

  end
end
