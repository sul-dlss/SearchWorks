class AccessPanels
  class Sfx < ::AccessPanel
    delegate :present?, to: :links

    def links
      eds_links || index_sfx_links
    end

    private

    def eds_links
      @document.eds_links.sfx if @document.eds_links.present?
    end

    def index_sfx_links
      @document&.index_links&.sfx
    end
  end
end
