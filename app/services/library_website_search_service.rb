# frozen_string_literal: true

class LibraryWebsiteSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.LIBRARY_WEBSITE_QUERY_API_URL.to_s
    options[:response_class] ||= Response
    super
  end

  class HighlightedFacetItem < AbstractSearchService::HighlightedFacetItem
    def facet_field_to_param
      "f[0]=#{CGI.escape(value)}"
    end
  end

  class Response < AbstractSearchService::Response
    HIGHLIGHTED_FACET_FIELD = 'document_type_facet'
    HIGHLIGHTED_FACET_CLASS = LibraryWebsiteSearchService::HighlightedFacetItem
    QUERY_URL = Settings.LIBRARY_WEBSITE_QUERY_API_URL.freeze

    def total
      nil # TODO: library web scrape doesn't provide the total number of hits
    end

    # @return [Array<AbstractSearchService::Result>]
    def results
      doc.css('.search-results .views-row').first(Settings.MAX_RESULTS).collect do |hit|
        next if hit.blank?

        title = hit.at_css('.views-field-title .field-content a')
        next if title.blank?

        result = AbstractSearchService::Result.new
        result.title = title.text
        result.link = title['href']
        result.description = hit.at_css('.views-field-body-value .field-content').try(:text)
        result.breadcrumbs = hit.at_css('.result-breadcrumbs span').try(:text)
        result
      end.compact
    end

    # @return [Array<Hash>] mimics Solr facets response
    def facets
      facet_response = [{
        'name' => HIGHLIGHTED_FACET_FIELD
      }]
      doc.css('.facetapi-facetapi-links').each do |facet_group|
        facet_response.first['items'] = parse_facet_group(facet_group)
      end
      facet_response
    end

    private

    def doc
      @doc ||= Nokogiri::HTML(@body)
    end

    # @return [Array<Hash>]
    def parse_facet_group(facet_group)
      facet_group.css('li').collect do |facet|
        href = facet.at_css('a')['href']
        match = facet.at_css('a').text.to_s.match(/^(.*)\s+\((\d+)\)/)
        next unless match
        {
          'value' => CGI.parse(URI.parse(href).query)['f[0]'].first, # search term is in the href params
          'label' => match[1].to_s,
          'hits' => match[2].to_i
        }
      end.compact
    end
  end
end
