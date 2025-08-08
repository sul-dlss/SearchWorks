# frozen_string_literal: true

# Uses the Blacklight JSON API to search and then extracts select EDS fields
class ArticleSearchService < AbstractSearchService
  def initialize(**)
    @query_url = Settings.article.api_url.to_s
    @response_class = Response
    super
  end

  class Response < AbstractSearchService::Response
    HIGHLIGHTED_FACET_FIELD = 'eds_publication_type_facet'

    def total
      json['response']['pages']['total_count'].to_i
    end

    def results
      solr_docs = json['response']['docs']
      solr_docs.collect do |doc|
        format = doc['eds_publication_type']
        ArticleResult.new(
          link: format(Settings.article.fetch_url, id: doc['id']),
          title: doc['eds_title'],
          format:,
          journal: doc['eds_source_title'],
          description: doc['eds_abstract'],
          author: doc['eds_authors']&.first,
          pub_date: doc['eds_publication_date'],
          composed_title: doc['eds_composed_title'],
          resource_links: doc['links']
        )
      end
    end
  end
end
