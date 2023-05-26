# index_links returns a Links::Link object for each :marc_link_struct value.
# index_links are displayed on access panels and get different treatment
# for link_text than marc_links created in the MarcLinks module.
module IndexLinks
  def index_links
    @index_links ||= Links.new(
      fetch(:marc_links_struct, []).map do |link_struct|
        IndexLinkProcessor.new(self, link_struct).to_searchworks_link
      end
    )
  end

  class IndexLinkProcessor
    attr_reader :document, :link_struct

    def initialize(document, link_struct)
      @document = document
      @link_struct = link_struct
    end

    def to_searchworks_link
      Links::Link.new(link_struct.merge({ link_text:, href: }))
    end

    private

    def href
      @href ||= Links.ezproxy_url(link_struct[:href], document) || link_struct[:href]
    end

    def link_text
      if link_struct[:finding_aid]
        'Online Archive of California'
      elsif link_struct[:sfx]
        'Find full text'
      elsif link_struct[:href]
        link_host
      else
        link_struct[:link_text]
      end
    end

    def link_host
      uri = URI.parse(Addressable::URI.encode(link_struct[:href].strip))
      host = uri.host
      if host =~ Links::PROXY_REGEX && uri.query
        query = CGI.parse(uri.query)
        host = URI.parse(query['url'].first).host if query['url'].present?
      end
      host || link_struct[:href]
    rescue URI::InvalidURIError, Addressable::URI::InvalidURIError
      link_struct[:href]
    end
  end
end
