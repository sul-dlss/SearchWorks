class AccessPanels
  class TemporaryAccess < ::AccessPanel
    def present?
      return false unless Settings.HATHI_ETAS_ACCESS

      stanford_only_hathi_links.present?
    end

    def link
      stanford_only_hathi_links.first
    end

    private

    def stanford_only_hathi_links
      @document.hathi_links.all.select(&:stanford_only?)
    end
  end
end
