# frozen_string_literal: true

# Uses the Blacklight JSON API to search and then extracts select Catalog fields
class CatalogSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.CATALOG.API_URL.to_s
    options[:response_class] ||= Response
    super
  end

  class Response < AbstractSearchService::Response
    QUERY_URL = Settings.CATALOG.QUERY_URL

    def total
      json['response']['pages']['total_count'].to_i
    end

    def results
      solr_docs = json['response']['docs']
      solr_docs.collect do |doc|
        result = AbstractSearchService::Result.new
        result.title = doc['title_display'] || doc['title_full_display']
        result.link = format(Settings.CATALOG.FETCH_URL.to_s, id: doc['id'])
        result.physical = doc['physical']&.first
        result.author = doc['author_person_display']&.first
        result.format = doc['format_main_ssim']&.first
        result.icon = 'notebook.svg'

        # Break up the HTML string into the pieces we use
        html = Nokogiri::HTML(doc['fulltext_link_html']&.first)
        link = html.css('a').first&.to_html
        result.fulltext_link_html = "<span class=\"text-green\">Available online ⮕</span> #{link}" if link

        # result.year = doc['publication_year_isi']
        result.id = doc['id']

        result.description = doc['summary_display'].try(:join)
        result
      end
    end

    private

    def json
      @json ||= JSON.parse(@body)
    end
  end
end
