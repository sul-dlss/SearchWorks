# frozen_string_literal: true

# Uses the Blacklight JSON API to search and then extracts select Catalog fields
class CatalogSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.CATALOG_QUERY_API_URL.to_s
    options[:response_class] ||= Response
    super
  end

  class Response < AbstractSearchService::Response
    HIGHLIGHTED_FACET_FIELD = 'format_main_ssim'
    QUERY_URL = Settings.CATALOG_QUERY_URL
    ADDITIONAL_FACET_TARGET = 'Database'

    def total
      json['response']['pages']['total_count'].to_i
    end

    def results
      solr_docs = json['response']['docs']
      solr_docs.collect do |doc|
        result = AbstractSearchService::Result.new
        result.title = doc['title_display'] || doc['title_full_display']
        result.link = format(Settings.CATALOG_FETCH_URL.to_s, id: doc['id'])
        result.author = doc['author_person_display']&.first
        result.imprint = doc['imprint_display']&.first
        result.fulltext_link_html = doc['fulltext_link_html']&.first
        result.temporary_access_link_html = doc['temporary_access_link_html']&.first
        result.id = doc['id']

        result.description = doc['summary_display'].try(:join) || find_description_in_marcxml(doc['marcbib_xml'])
        result
      end
    end

    def facets
      json['response']['facets']
    end

    def additional_facet_details(q)
      return nil if additional_facet_item['hits'].to_i.zero?

      Struct.new(:hits, :href).new(
        additional_facet_item['hits'],
        "#{format(QUERY_URL, q: CGI.escape(q))}&f[#{HIGHLIGHTED_FACET_FIELD}][]=#{ADDITIONAL_FACET_TARGET}"
      )
    end

    private

    def json
      @json ||= JSON.parse(@body)
    end

    def find_description_in_marcxml(xml)
      doc = Nokogiri::XML(xml)
      doc.xpath('/marc:collection/marc:record/marc:datafield[@tag="500" or @tag="520"]/marc:subfield[@code="a"]',
                '/marc:collection/marc:record/marc:datafield[@tag="920"]/marc:subfield[@code="b"]',
                'marc' => 'http://www.loc.gov/MARC21/slim').text
    end

    def additional_facet_item
      facet = facets.find do |f|
        f['name'] == HIGHLIGHTED_FACET_FIELD
      end || {}

      (facet['items'] || []).find do |item|
        item['label'] == ADDITIONAL_FACET_TARGET
      end || { 'hits' => 0 }
    end
  end
end
