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
          html: link_html(link_field),
          text: link_text(link_field),
          href: link_field,
          fulltext: link_is_fulltext?(link_field),
          stanford_only: link_is_stanford_only?(link_field),
          finding_aid: link_is_finding_aid?(link_field),
          sfx: link_is_sfx?(link_field),
          managed_purl: link_is_managed_purl?(link_field)
        )
      end
    end

    private

    def link_html(link_field)
      "<a href='#{link_field}'#{" class='sfx'".html_safe if link_is_sfx?(link_field)}>#{link_text(link_field)}</a>"
    end

    def link_text(link_field)
      if link_is_finding_aid?(link_field)
        'Online Archive of California'
      elsif link_is_sfx?(link_field)
        'Find full text'
      else
        link_host(link_field)
      end
    end

    def link_is_finding_aid?(link_field)
      link_field =~ %r{oac\.cdlib\.org(\/findaid)?\/ark:}
    end

    def link_fields
      [
        @document[:url_fulltext],
        @document[:url_suppl],
        @document[:url_sfx],
        @document[:managed_purl_urls]
      ].flatten.compact.uniq
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

    def link_is_managed_purl?(link)
      @document[:managed_purl_urls] &&
        @document[:managed_purl_urls].include?(link)
    end

    def link_host(link_field)
      uri = URI.parse(Addressable::URI.encode(link_field.strip))
      host = uri.host
      if host =~ SearchWorks::Links::PROXY_REGEX
        if uri.query && (query = CGI.parse(uri.query))['url'].present?
          host = URI.parse(query['url'].first).host
        end
      end
      host || link_field
    rescue URI::InvalidURIError
      link_field
    end
  end
end
