# frozen_string_literal: true

# Uses the LibGuides API to search
class ExhibitsSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.EXHIBITS.API_URL.to_s
    options[:response_class] ||= Response
    super
  end

  class Response < AbstractSearchService::Response
    def results
      json.collect do |exhibit|
        result = AbstractSearchService::Result.new
        result.title = exhibit['title']
        result.link = format(Settings.EXHIBITS.LINK_URL.to_s, id: exhibit['slug'])
        result.description = exhibit['subtitle']
        result.thumbnail = exhibit['thumbnail_url']
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
