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
         text: link_text(link_field),
         fulltext: link_is_fulltext?(link_field),
         stanford_only: link_is_stanford_only?(link_field),
         finding_aid: link_is_finding_aid?(link_field),
         sfx: link_is_sfx?(link_field)
        )
      end
    end

    private

    def link_text(link_field)
      if link_is_finding_aid?(link_field)
        "<a href='#{link_field}'>Online Archive of California</a>"
      elsif link_is_sfx?(link_field)
        "<a href='#{link_field}' class='sfx'>Find full text</a>"
      else
        "<a href='#{link_field}'>#{link_host(link_field)}</a>"
      end
    end

    def link_is_finding_aid?(link_field)
      link_field =~ /oac\.cdlib\.org\/findaid/
    end
    def link_fields
      [@document[:url_fulltext], @document[:url_suppl], @document[:url_sfx]].flatten.compact.uniq
    end
    def link_is_fulltext?(link)
      @document[:url_fulltext] &&
      @document[:url_fulltext].include?(link)
    end
    def link_is_stanford_only?(link)
      @document[:url_restricted] &&
      @document[:url_restricted].include?(link)
    end

    def link_is_sfx?(link)
      @document[:url_sfx] &&
      @document[:url_sfx].include?(link)
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
