# Uses the Blacklight JSON API to search and then extracts select EDS fields
class ArticleSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.EDS_QUERY_API_URL.to_s
    options[:response_class] ||= Response
    super
  end

  class Response < AbstractSearchService::Response
    def total
      json['response']['pages']['total_count'].to_i
    end

    def results
      solr_docs = json['response']['docs']
      solr_docs.collect do |doc|
        result = AbstractSearchService::Result.new
        result.title = doc['eds_title']
        result.link = Settings.EDS_FETCH_URL.to_s % { id: doc['id'] }
        result.id = doc['id']
        result.description = doc['eds_abstract']
        result
      end
    end

    def facets
      json['response']['facets']
    end

    private

    def json
      @json ||= JSON.parse(@body)
    end
  end
end
