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

  def preferred_online_links
    @preferred_online_links ||= prioritized_marc_fulltext_links
  end

  def prioritized_marc_fulltext_links
    marc_fulltext_links = marc_links&.fulltext

    return [] if marc_fulltext_links.blank?

    # If there are no EBSCO links, the 856s might be in a useful order in the MARC record
    return marc_fulltext_links unless marc_fulltext_links.any?(&:ebscohost?)

    # But if there are EBSCO links, we want to prioritize them ourselves
    open_access, other_links = marc_fulltext_links.partition(&:open_access?)
    aggregator_links, licensed_links = other_links.partition(&:aggregator?)

    licensed_links + open_access + aggregator_links
  end

  def has_finding_aid?
    preferred_finding_aid&.href.present?
  end

  def preferred_finding_aid
    marc_links&.finding_aid&.first
  end

  class MarcLinkProcessor
    attr_reader :document, :link_struct

    def initialize(document, link_struct)
      @document = document
      @link_struct = link_struct
    end

    def to_link
      Links::Link.new(link_struct.merge({ href: link_struct[:href], ezproxy_href: proxied_url, link_text:, finding_aid: finding_aid?, sort: }))
    end

    private

    def link_text
      if finding_aid?
        finding_aid_link_text
      else
        link_struct[:link_text]
      end
    end

    def finding_aid?
      link_struct[:material_type]&.downcase&.include?('finding aid') || link_struct[:note]&.downcase&.include?('finding aid')
    end

    def archives_finding_aid?
      finding_aid? && link_struct[:href]&.include?('//archives.stanford.edu')
    end

    def oac_finding_aid?
      finding_aid? && link_struct[:href]&.include?('oac.cdlib.org')
    end

    def finding_aid_link_text
      if archives_finding_aid?
        'Archival Collections at Stanford'
      elsif oac_finding_aid?
        'Online Archive of California'
      else
        link_struct[:link_text]
      end
    end

    def sort
      if finding_aid?
        archives_finding_aid? ? '0' : '1'
      else
        link_struct[:sort].to_s
      end
    end

    def proxied_url
      Links::Ezproxy.new(
        url: link_struct[:href], link_title: link_struct[:link_title], document:
      ).to_proxied_url
    end
  end
end
