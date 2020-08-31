# frozen_string_literal: true

# Uses the Library Website API to search
class LibraryWebsiteApiSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.LIBRARY_WEBSITE.API_URL.to_s
    options[:response_class] ||= Response
    super
  end

  class HighlightedFacetItem < AbstractSearchService::HighlightedFacetItem
    def facet_field_to_param
      "f[0]=#{CGI.escape(value)}"
    end
  end

  class Response < AbstractSearchService::Response
    HIGHLIGHTED_FACET_FIELD = 'format_facet'
    HIGHLIGHTED_FACET_CLASS = LibraryWebsiteApiSearchService::HighlightedFacetItem
    QUERY_URL = Settings.LIBRARY_WEBSITE.QUERY_URL.freeze

    def results
    sanitizer = Rails::Html::FullSanitizer.new
      Array.wrap(json['results']).first(3).collect do |doc|
        result = AbstractSearchService::Result.new
        result.title = doc['title']
        result.link = doc['url']
        result.description = sanitizer.sanitize(doc['description'])
        result.breadcrumbs = doc['breadcrumbs']&.drop(1)
        result
      end
    end

    def facets
      facet_response = [{
        'name' => HIGHLIGHTED_FACET_FIELD
      }]
      facet_response.first['items'] = json['facets']['items'].map do |facet|
        {
          'value' => facet['term']&.first,
          'label' => facet['label'],
          'hits' => facet['hits'],
        }
      end
      facet_response
    end

    def total
      facets = json["facets"]["items"]
      facets.sum {|facet| facet["hits"]}
    end

    private

    def json
      @json ||= JSON.parse(@body)
    end

  end
end
