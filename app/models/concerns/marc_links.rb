# frozen_string_literal: true

# marc_links returns a Links::Link object for each :marc_link_struct value.
# marc_links are displayed along with other record metadata and have the default
# link_text values vs. links created in the IndexLinks module that modifies the link_text values.
module MarcLinks
  def marc_links
    @marc_links ||= Links.new(fetch(:marc_links_struct, []).map do |link_struct|
      MarcLinkProcessor.new(self, link_struct).to_marc_link
    end)
  end

  class MarcLinkProcessor
    attr_reader :document, :link_struct

    def initialize(document, link_struct)
      @document = document
      @link_struct = link_struct
    end

    def to_marc_link
      Links::Link.new(link_struct.merge({ href: }))
    end

    private

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
