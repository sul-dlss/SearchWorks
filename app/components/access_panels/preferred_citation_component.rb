# frozen_string_literal: true

module AccessPanels
  class PreferredCitationComponent < AccessPanels::Base
    def preferred_citation
      document.citations['preferred'] if document.citable?
    end

    def render?
      preferred_citation.present?
    end
  end
end
