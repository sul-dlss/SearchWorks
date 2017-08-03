# Uses the Blacklight JSON API to search and then extracts select EDS fields
class ArticleSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.EDS_QUERY_URL.to_s
    options[:response_class] ||= Response
    super
  end

  class Response < AbstractSearchService::Response
    def total
      @json ||= JSON.parse(@body)
      @json['response']['pages']['total_count'].to_i
    end

    def results
      @json ||= JSON.parse(@body)
      solr_docs = @json['response']['docs']
      solr_docs.collect do |doc|
        {
          title:        doc['eds_title'],
          description:  doc['eds_abstract'],
          url:          Settings.EDS_FETCH_URL.to_s % { id: doc['id'] }
        }
      end
    end

    def facets
      @json ||= JSON.parse(@body)
      @json['response']['facets']
    end
  end
end
