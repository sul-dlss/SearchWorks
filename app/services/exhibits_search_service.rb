# frozen_string_literal: true

# Uses the LibGuides API to search
class ExhibitsSearchService < AbstractSearchService
  def initialize(**)
    @query_url = settings.api_url.to_s
    @response_class = Response
    super
  end

  private

  def settings
    Settings.exhibits
  end

  class Response < AbstractSearchService::Response
    def results
      json.first(num_results).collect do |exhibit|
        SearchResult.new(
          title: exhibit['title'],
          link: format(settings.link_url, id: exhibit['slug']),
          description: exhibit['subtitle'],
          thumbnail: exhibit['thumbnail_url']
        )
      end
    end

    def num_results
      settings.num_results_shown
    end

    # NOTE: This will never return more than 8 results.
    def total
      json.length
    end

    private

    def settings
      Settings.exhibits
    end
  end
end
