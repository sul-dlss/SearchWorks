module RequestLinks
  class FindingAidRequestLinkComponent < LocationRequestLinkComponent
    def render?
      link_href.present?
    end

    def link_href
      document&.index_links&.finding_aid&.first&.href
    end

    def link_text
      I18n.t('searchworks.request_link.finding_aid')
    end
  end
end
