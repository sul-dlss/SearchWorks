class AccessPanels
  class Online < ::AccessPanel
    delegate :present?, to: :links

    def links
      sfx_links || marc_fulltext_links || eds_links
    end

    private

    def sfx_links
      @document.index_links.sfx if @document.index_links.sfx.present?
    end

    def marc_fulltext_links
      @document.marc_links.fulltext if @document.marc_links.present?
    end

    def eds_links
      @document.eds_links.fulltext if @document.eds_links.present?
    end
  end
end
