class LibraryWebsiteSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.LIBRARY_WEBSITE_QUERY_API_URL.to_s
    options[:response_class] ||= Response
    super
  end

  class Response < AbstractSearchService::Response
    HIGHLIGHTED_FACET_FIELD = 'document_type_facet'.freeze
    QUERY_URL = Settings.LIBRARY_WEBSITE_QUERY_API_URL.freeze

    def total
      nil # TODO: library web scrape doesn't provide the total number of hits
    end

    # @return [Array<AbstractSearchService::Result>]
    def results
      doc.css('.search-results .views-row').first(Settings.MAX_RESULTS).collect do |hit|
        result = AbstractSearchService::Result.new
        result.title = hit.at_css('.views-field-title .field-content a').text
        result.link = hit.at_css('.views-field-title .field-content a')['href']
        result.description = hit.at_css('.views-field-body-value .field-content').text
        result.breadcrumbs = hit.at_css('.result-breadcrumbs span').text
        result
      end
    end

    # @return [Array<Hash>] mimics Solr facets response
    def facets
      facet_response = [ {
        'name' => HIGHLIGHTED_FACET_FIELD
      } ]
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
      facet_group.css('li a').collect do |facet|
        match = facet.text.to_s.match(/^(.*)\s+\((\d+)\)/)
        {
          'value' => match[1].to_s,
          'label' => match[1].to_s,
          'hits' => match[2].to_i
        } if match
      end.compact
    end
  end
end
