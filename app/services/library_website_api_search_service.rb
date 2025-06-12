# frozen_string_literal: true

# Uses the Library Website API to search
class LibraryWebsiteApiSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.LIBRARY_WEBSITE.API_URL.to_s
    options[:response_class] ||= Response
    super
  end

  class Response < AbstractSearchService::Response
    QUERY_URL = Settings.LIBRARY_WEBSITE.QUERY_URL.freeze

    def results
      sanitizer = Rails::Html::FullSanitizer.new

      return unless json['data']

      json['data'].map do |doc|
        SearchResult.new(
          title: doc.dig('attributes', 'title'),
          link: doc.dig('attributes', 'path', 'alias'),
          description: sanitizer.sanitize(doc.dig('attributes', 'su_page_description'))
        )
      end
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
