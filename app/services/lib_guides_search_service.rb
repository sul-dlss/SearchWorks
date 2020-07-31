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
      json.first(5).collect do |doc|
        result = AbstractSearchService::Result.new
        result.title = doc['name']
        result.link = doc['url']
        result.id = doc['slug_id']
        result.description = doc['description']
        result
      end
    end

    def facets
      []
    end

    def total
      json.length
    end

    private

    def json
      @json ||= JSON.parse(@body)
    end
    
  end
end
