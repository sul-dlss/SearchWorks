# frozen_string_literal: true

module AccessPanels
  # Displays related items, additional finding aids, and provides a place for plugGoogleBookContent() to add book cover previews
  class RelatedComponent < AccessPanels::Base
    delegate :additional_finding_aids?, :additional_finding_aids, to: :document

    def oclc
      document[:oclc]
    end

    private

    def hidden
      oclc.blank?
    end

    def finding_aid_class(link)
      # OAC finding aids use both 'www.oac.cdlib.org' and 'oac.cdlib.org'
      'oac' if link.href&.include?('oac.cdlib.org')
    end
  end
end
