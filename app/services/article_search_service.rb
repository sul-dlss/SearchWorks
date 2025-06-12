# frozen_string_literal: true

# Uses the Blacklight JSON API to search and then extracts select EDS fields
class ArticleSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.article.api_url.to_s
    options[:response_class] ||= Response
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
        result = SearchResult.new(
          link: format(Settings.article.fetch_url, id: doc['id']),
          title: doc['eds_title'],
          format: doc['eds_publication_type'],
          journal: doc['eds_source_title'],
          icon: 'notebook.svg',
          description: doc['eds_abstract']
        )

        # Break up the HTML string into the pieces we use
        html = Nokogiri::HTML(doc['fulltext_link_html'])
        online_label = html.css('.online-label').first
        if online_label
          online_label['class'] += ' badge rounded-pill ms-2'
          result.title += online_label.to_html
        end
        stanford_only = html.css('.stanford-only').first
        result.fulltext_link_html = html.css('a').first&.to_html
        result.fulltext_link_html += stanford_only.to_html if stanford_only
        result.author = doc['eds_authors']&.first
        # result.year = doc['pub_year_tisim']&.html_safe
        result.description = doc['eds_abstract']
        result
      end
    end

    private

    def json
      @json ||= JSON.parse(@body)
    end
  end
end
