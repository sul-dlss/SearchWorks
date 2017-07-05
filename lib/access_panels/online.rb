class AccessPanels
  class Online < ::AccessPanel
    def links
      sfx_links || marc_fulltext_links
    end

    # We are using present? for both marc/solr links but also EDS links
    # We'll use another method of accessing the EDS links given that they
    # don't match the same format/behavior as the marc/solr links
    def present?
      links.present? || @document['eds_fulltext_links'].present?
    end

    private

    def sfx_links
      @document.index_links.sfx if @document.index_links.sfx.present?
    end

    def marc_fulltext_links
      @document.marc_links.fulltext if @document.marc_links.present?
    end
  end
end
