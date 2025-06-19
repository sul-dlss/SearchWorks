# frozen_string_literal: true

# Uses the Library Website API to search
class LibraryWebsiteApiSearchService < AbstractSearchService
  def initialize(**)
    @query_url = Settings.library_website.api_url.to_s
    @response_class = Response
    super
  end

  class Response < AbstractSearchService::Response
    def results
      sanitizer = Rails::Html::FullSanitizer.new

      return unless json['data']

      json['data'].map do |doc|
        LibraryWebsiteResult.new(
          title: doc.dig('attributes', 'title'),
          link: format(Settings.library_website.link_url, id: doc.dig('attributes', 'path', 'alias').delete_prefix('/')),
          description: sanitizer.sanitize(doc.dig('attributes', 'su_page_description'))
        )
      end
    end

    def total
      json.dig('meta', 'count')
    end
  end
end
