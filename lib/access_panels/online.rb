class Online < AccessPanel
  delegate :present?, to: :links
  def links
    unless @document.is_a_collection_member?
      if @document.index_links.sfx.present?
        @document.index_links.sfx
      elsif @document.marc_links.present?
        @document.marc_links.fulltext
      end
    end
  end
end
