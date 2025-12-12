# frozen_string_literal: true

module AccessPanels
  # Displays related items, additional finding aids, and provides a place for plugGoogleBookContent() to add book cover previews
  class RelatedComponent < AccessPanels::Base
    def oclc
      document.oclc_number
    end

    def additional_finding_aids?
      finding_aids.length > 1
    end

    def additional_finding_aids
      return nil unless additional_finding_aids?

      finding_aids.drop(1)
    end

    private

    def hidden # rubocop:disable Naming/PredicateMethod
      oclc.blank? && !additional_finding_aids?
    end

    def finding_aid_class(link)
      # OAC finding aids use both 'www.oac.cdlib.org' and 'oac.cdlib.org'
      'oac' if link.href&.include?('oac.cdlib.org')
    end

    def finding_aids
      document.marc_links&.finding_aid || []
    end
  end
end
