# frozen_string_literal: true

# index_links returns a Links::Link object for each :marc_link_struct value.
# index_links are displayed on access panels and get different treatment
# for link_text than marc_links created in the MarcLinks module.
module IndexLinks
  def index_links
    @index_links ||= Links.new(
      fetch(:marc_links_struct, []).map do |link_struct|
        IndexLinkProcessor.new(self, link_struct).to_index_link
      end
    )
  end

  def has_finding_aid?
    index_links.finding_aid.first&.href.present?
  end

  module Structures
    def finding_aid?
      link_struct[:material_type]&.downcase&.include?('finding aid') || link_struct[:note]&.downcase&.include?('finding aid')
    end

    def sfx?
      link_struct[:sfx]
    end

    def href?
      link_struct[:href].present?
    end

    def struct_link_text
      link_struct[:link_text]
    end
  end

  class IndexLinkProcessor
    include IndexLinks::Structures

    attr_reader :document, :link_struct

    def initialize(document, link_struct)
      @document = document
      @link_struct = link_struct
    end

    def to_index_link
      Links::Link.new(link_struct.merge({ link_text:, href: }))
    end

    private

    def link_text
      if finding_aid?
        'Online Archive of California'
      elsif sfx?
        'Find full text'
      elsif href?
        link_host
      else
        struct_link_text
      end
    end

    def href
      proxied_url || link_struct[:href]
    end

    def proxied_url
      Links::Ezproxy.new(
        url: link_struct[:href], link_title: link_struct[:link_title], document:
      ).to_proxied_url
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
