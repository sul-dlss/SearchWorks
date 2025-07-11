# frozen_string_literal: true

module AccessPanels
  # Displays online links and provides a place for plugGoogleBookContent() to add book cover previews
  class OnlineComponent < AccessPanels::Base
    def links
      @document.preferred_online_links
    end

    def render?
      links.present?
    end

    def display_connection_problem_links?
      sfx_links.any? || document.is_a_database? || document.preferred_online_links.any?(&:stanford_only?)
    end

    def sfx_links
      return [] unless @document.marc_links.sfx.present?

      @document.marc_links.sfx
    end
  end
end
