# frozen_string_literal: true

# Uses the Library Website API to search
class LibraryWebsiteApiSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.library_website.api_url.to_s
    options[:response_class] ||= Response
    super
  end

  class Response < AbstractSearchService::Response
    def results
      sanitizer = Rails::Html::FullSanitizer.new

      return unless json['data']

      json['data'].map do |doc|
        LibraryWebsiteResult.new(
          title: doc.dig('attributes', 'title'),
          link: doc.dig('attributes', 'path', 'alias'),
          description: sanitizer.sanitize(doc.dig('attributes', 'su_page_description'))
        )
      end
    end

    def total
      json.dig('meta', 'count')
    end
  end
end
