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
      Settings.libguides.api_url.to_s,
      '?',
      {
        site_id: Settings.libguides.site_id,
        key: Settings.libguides.key,
        status: 1,
        sort_by: 'relevance',
      }.to_query,
      '&search_terms=%{q}'
    ].join()
  end

  class Response < AbstractSearchService::Response
    def results
      json.first(num_results).collect do |doc|
        SearchResult.new(
          title: doc['name'],
          link: doc['url']
        )
      end
    end

    def num_results
      Settings.libguides.num_results_shown
    end

    # The guides api will only return 100 results
    # If there are more than 100 results there is no way of knowing the correct number
    # Instead of displaying a correct number we don't display the number if the results == 100
    # Otherwise we have a correct length and can display the number of results.
    def total
      json.length
    end

    private

    def json
      @json ||= JSON.parse(@body)
    end
  end
end
