# IndexLinks module is mixed into the SolrDocument.
# It proveds an #index_links method which will return
# Link objects for every link field in the SolrDocument.

module IndexLinks
  def index_links
    @index_links ||= IndexLinks::Processor.new(self)
  end
  private
  class Processor < SearchWorks::Links
    def all
      link_fields.map do |link_field|
        SearchWorks::Links::Link.new(
         text: "<a href='#{link_field}'>#{link_host(link_field)}</a>",
         fulltext: link_is_fulltext?(link_field),
         stanford_only: link_is_stanford_only?(link_field)
        )
      end
    end
    private
    def link_fields
      [@document[:url_fulltext], @document[:url_suppl]].flatten.compact.uniq
    end
    def link_is_fulltext?(link)
      @document[:url_fulltext] &&
      @document[:url_fulltext].include?(link)
    end
    def link_is_stanford_only?(link)
      @document[:url_restricted] &&
      @document[:url_restricted].include?(link)
    end
    def link_host(link_field)
      uri = URI.parse(link_field)
      host = uri.host
      if host =~ /ezproxy\.stanford\.edu/
        query = CGI.parse(uri.query)
        if query['url'].present?
          host = URI.parse(query['url'].first).host
        end
      end
      host
    end
  end
end
