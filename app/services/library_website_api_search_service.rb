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

      # TODO: remove the json['results'] condition after D9 launch
      if json['results']
        json['results'].first(3).map do |doc|
          result = AbstractSearchService::Result.new
          result.title = doc['title']
          result.link = doc['url']
          result.description = sanitizer.sanitize(doc['description'])
          result.breadcrumbs = doc['breadcrumbs']&.drop(1)
          result
        end
      elsif json['data']
        json['data'].map do |doc|
          result = AbstractSearchService::Result.new
          result.title = doc.dig('attributes', 'title')
          result.link = doc.dig('attributes', 'path', 'alias')
          result.description = sanitizer.sanitize(doc.dig('attributes', 'su_page_description'))
          result
        end
      end
    end

    # Drupal 9 data for the library website does not support facets currently
    # We still to implement the method to override AbstractSearchService's method, which throws a NotImplementedError
    # TODO: remove the json['facets'] condition after D9 launch
    def facets
      return [] unless json['facets']

        [{
          'name' => HIGHLIGHTED_FACET_FIELD,
          'items' => json['facets']['items'].map do |facet|
            {
              'value' => facet['term']&.first,
              'label' => facet['label'],
              'hits' => facet['hits']
            }
          end
        }]
    end

    # TODO: remove the json['facets'] condition after D9 launch
    def total
      return json.dig('meta', 'count') unless json['facets']

        facets = json["facets"]["items"]
        facets.sum {|facet| facet["hits"]}
    end

    private

    def json
      @json ||= JSON.parse(@body)
    end

  end
end
