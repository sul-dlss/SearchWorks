# IndexLinks module is mixed into the SolrDocument.
# It proveds an #index_links method which will return
# Link objects for every link field in the SolrDocument.
module IndexLinks
  def index_links
    @index_links ||= SearchWorks::Links.new(link_fields.map { |link_field| IndexLinkProcessor.new(self, link_field).to_searchworks_link })
  end

  private

  def link_fields
    [
      self[:url_fulltext],
      self[:url_suppl],
      self[:url_sfx],
      self[:managed_purl_urls]
    ].flatten.compact.uniq
  end

  class IndexLinkProcessor
    attr_reader :document, :link_field

    def initialize(document, link_field)
      @document = document
      @link_field = link_field
    end

    def to_searchworks_link
      SearchWorks::Links::Link.new(
        link_text: link_text,
        href: link_field,
        fulltext: link_is_fulltext?,
        stanford_only: link_is_stanford_only?,
        finding_aid: link_is_finding_aid?,
        sfx: link_is_sfx?,
        managed_purl: link_is_managed_purl?
      )
    end

    private

    def link_text
      if link_is_finding_aid?
        'Online Archive of California'
      elsif link_is_sfx?
        'Find full text'
      else
        link_host
      end
    end

    def link_is_finding_aid?
      link_field =~ %r{oac\.cdlib\.org(/findaid)?/ark:}
    end

    def link_is_fulltext?
      @document[:url_fulltext] &&
        @document[:url_fulltext].include?(link_field)
    end

    def link_is_stanford_only?
      @document[:url_restricted] &&
        @document[:url_restricted].include?(link_field)
    end

    def link_is_sfx?
      @document[:url_sfx] &&
        @document[:url_sfx].include?(link_field)
    end

    def link_is_managed_purl?
      @document[:managed_purl_urls] &&
        @document[:managed_purl_urls].include?(link_field)
    end

    def link_host
      uri = URI.parse(Addressable::URI.encode(link_field.strip))
      host = uri.host
      if host =~ SearchWorks::Links::PROXY_REGEX && uri.query
        query = CGI.parse(uri.query)
        host = URI.parse(query['url'].first).host if query['url'].present?
      end
      host || link_field
    rescue URI::InvalidURIError, Addressable::URI::InvalidURIError
      link_field
    end
  end
end
