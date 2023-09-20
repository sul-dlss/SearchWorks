module AccessPanels
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
      return [] unless @document.index_links.sfx.present?

      @document.index_links.sfx
    end
  end
end
