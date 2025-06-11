# frozen_string_literal: true

# Uses the LibGuides API to search
class ExhibitsSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= settings.API_URL.to_s
    options[:response_class] ||= Response
    super
  end

  private

  def settings
    Settings.EXHIBITS
  end

  class Response < AbstractSearchService::Response
    def results
      json.first(num_results).collect do |exhibit|
        result = AbstractSearchService::Result.new
        result.title = exhibit['title']
        result.link = format(settings.LINK_URL.to_s, id: exhibit['slug'])
        result.description = exhibit['subtitle']
        result.thumbnail = exhibit['thumbnail_url']
        result
      end
    end

    def num_results
      settings.NUM_RESULTS_SHOWN
    end

    # NOTE: This will never return more than 8 results.
    def total
      json.length
    end

    private

    def settings
      Settings.EXHIBITS
    end

    def json
      @json ||= JSON.parse(@body)
    end
  end
end
