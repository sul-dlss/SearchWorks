# frozen_string_literal: true

# marc_links returns a Links::Link object for each :marc_link_struct value.
# marc_links are displayed along with other record metadata and have the default
# link_text values vs. links created in the AccessPanelLinks module that modifies the link_text values.
module MarcLinks
  def marc_links
    @marc_links ||= Links.new(fetch(:marc_links_struct, []).filter_map do |link_struct|
      MarcLinkProcessor.new(self, link_struct).to_link
    end)
  end

  class MarcLinkProcessor
    attr_reader :document, :link_struct

    def initialize(document, link_struct)
      @document = document
      @link_struct = link_struct
    end

    def to_link
      Links::Link.new(link_struct.merge({ href:, link_text:, finding_aid: finding_aid? }))
    end

    private

    def link_text
      if finding_aid?
        'Online Archive of California'
      elsif link_struct[:sfx]
        'Find full text'
      else
        link_struct[:link_text] || link_host
      end
    end

    def link_host
      return if link_struct[:href].blank?

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

    def finding_aid?
      link_struct[:material_type]&.downcase&.include?('finding aid') || link_struct[:note]&.downcase&.include?('finding aid')
    end

    def href
      proxied_url || link_struct[:href]
    end

    def proxied_url
      Links::Ezproxy.new(
        url: link_struct[:href], link_title: link_struct[:link_title], document:
      ).to_proxied_url
    end
  end
end
