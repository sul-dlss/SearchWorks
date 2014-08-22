class Online < AccessPanel
  delegate :present?, to: :links
  def links
    if @document.index_links.sfx.present?
      @document.index_links.sfx
    elsif @document.is_a_collection_member? &&
         !@document.has_image_behavior? &&
          @document.index_links.present?
      @document.index_links.fulltext
    elsif @document.marc_links.present?
      @document.marc_links.fulltext
    end
  end
end
