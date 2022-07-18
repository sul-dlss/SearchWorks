module RequestLinks
  class HooverArchiveRequestLinkComponent < LocationRequestLinkComponent
    def render?
      true
    end

    def call
      return 'Not available to request' if link_href.blank?

      super
    end

    def link_href
      document&.index_links&.finding_aid&.first&.href
    end
  end
end
