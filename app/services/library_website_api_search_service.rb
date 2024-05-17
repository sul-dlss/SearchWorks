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

      return unless json['data']

        json['data'].map do |doc|
          result = AbstractSearchService::Result.new
          result.title = doc.dig('attributes', 'title')
          result.link = doc.dig('attributes', 'path', 'alias')
          result.description = sanitizer.sanitize(doc.dig('attributes', 'su_page_description'))
          result
        end
    end

    # Drupal 9 data for the library website does not support facets currently.
    # We still need to implement the method to override AbstractSearchService's facet method
    # which throws a NotImplementedError if not implemented.
    # So we are implementing it here to return an empty array.
    def facets
      []
    end

    def total
      json.dig('meta', 'count')
    end

    private

    def json
      @json ||= JSON.parse(@body)
    end

  end
end
