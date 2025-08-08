# frozen_string_literal: true

# Uses the Blacklight JSON API to search and then extracts select Catalog fields
class CatalogSearchService < AbstractSearchService
  def initialize(**)
    @query_url = Settings.catalog.api_url.to_s
    @response_class = Response
    super
  end

  class Response < AbstractSearchService::Response
    def total
      json['response']['pages']['total_count'].to_i
    end

    def results
      solr_docs = json['response']['docs']
      solr_docs.collect do |doc|
        CatalogResult.new(
          title: doc['title_display'] || doc['title_full_display'],
          link: format(Settings.catalog.fetch_url, id: doc['id']),
          physical: doc['physical']&.first,
          author: doc['author_person_display']&.first,
          format: doc['format_hsim']&.first || doc['format_main_ssim']&.first,
          description: doc['summary_display'].try(:join),
          pub_year: doc['pub_year_ss'],
          fulltext_link_html: doc['fulltext_link_html']&.first
        )
      end
    end
  end
end
