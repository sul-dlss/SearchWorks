# frozen_string_literal: true

module AccessPanels
  class AvailabilityComponent < AccessPanels::Base
    def render?
      @document.holdings.libraries.compact_blank.any?(&:present?) || @document.preferred_online_links.present?
    end
  end
end
