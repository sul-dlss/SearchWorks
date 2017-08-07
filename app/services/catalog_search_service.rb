# Uses the Blacklight JSON API to search and then extracts select Catalog fields
class CatalogSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.CATALOG_QUERY_URL.to_s
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
          title:        doc['title_display'] || doc['title_full_display'],
          description:  doc['summary_display'].try(:join) || find_description_in_marcxml(doc['marcbib_xml']),
          url:          Settings.CATALOG_FETCH_URL.to_s % { id: doc['id'] }
        }
      end
    end

    def facets
      @json ||= JSON.parse(@body)
      @json['response']['facets']
    end

    private

    def find_description_in_marcxml(xml)
      doc = Nokogiri::XML(xml)
      doc.xpath('/marc:collection/marc:record/marc:datafield[@tag="500" or @tag="520"]/marc:subfield[@code="a"]',
                '/marc:collection/marc:record/marc:datafield[@tag="920"]/marc:subfield[@code="b"]',
                'marc' => 'http://www.loc.gov/MARC21/slim').text
    end
  end
end
