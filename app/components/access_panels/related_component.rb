# frozen_string_literal: true

module AccessPanels
  # Displays related items and provides a place for plugGoogleBookContent() to add book cover previews
  class RelatedComponent < AccessPanels::Base
    def oclc
      document[:oclc]
    end
  end
end
