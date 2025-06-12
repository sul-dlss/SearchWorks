# frozen_string_literal: true

# Uses the Blacklight JSON API to search and then extracts select Catalog fields
class EarthworksSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.EARTHWORKS.API_URL.to_s
    options[:response_class] ||= Response
    super
  end

  class Response < AbstractSearchService::Response
    QUERY_URL = Settings.EARTHWORKS.QUERY_URL

    def total
      json['meta']['pages']['total_count'].to_i
    end

    def results
      solr_docs = json['data']
      solr_docs.collect do |doc|
        SearchResult.new(
          title: doc.dig('attributes', 'title'),
          link: format(Settings.EARTHWORKS.FETCH_URL.to_s, id: doc['id']),
          author: doc.dig('attributes', 'dc_creator_sm', 'attributes', 'value'),
          description: doc.dig('attributes', 'dc_description_s', 'attributes', 'value')
        )
      end
    end

    private

    def json
      @json ||= JSON.parse(@body)
    end
  end
end
