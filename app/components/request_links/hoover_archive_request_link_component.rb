# frozen_string_literal: true

module RequestLinks
  class HooverArchiveRequestLinkComponent < LocationRequestLinkComponent
    def render?
      true
    end

    def call
      return 'Not available to request' if link_href.blank?

      super
    end

    # Hoover archive links go directly to the finding aid, unlike other finding
    # aid links which go to requests first and then out to the finding aid
    def link_text
      I18n.t('searchworks.request_link.finding_aid')
    end

    def link_href
      document&.index_links&.finding_aid&.first&.href
    end
  end
end
