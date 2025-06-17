# frozen_string_literal: true

# Uses the Blacklight JSON API to search and then extracts select Catalog fields
class CatalogSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.catalog.api_url.to_s
    options[:response_class] ||= Response
    super
  end

  class Response < AbstractSearchService::Response
    include IconMappingHelper

    def total
      json['response']['pages']['total_count'].to_i
    end

    def results # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      solr_docs = json['response']['docs']
      solr_docs.collect do |doc|
        format = doc['format_main_ssim']&.first
        result = SearchResult.new(
          title: doc['title_display'] || doc['title_full_display'],
          link: format(Settings.catalog.fetch_url, id: doc['id']),
          physical: doc['physical']&.first,
          author: doc['author_person_display']&.first,
          format: doc['format_main_ssim']&.first,
          icon: IconMappingHelper::HASH[format] || 'notebook.svg',
          description: doc['summary_display'].try(:join),
          pub_year: doc['pub_year_ss']
        )

        # Break up the HTML string into the pieces we use
        html = Nokogiri::HTML(doc['fulltext_link_html']&.first)
        link = html.css('a').first&.to_html
        result.fulltext_link_html = "<span class=\"text-green\">Available online ⮕</span> #{link}" if link

        result
      end
    end
  end
end
