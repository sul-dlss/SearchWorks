class Online < AccessPanel
  delegate :present?, to: :links
  def links
    if @document.marc_links.present?
      @document.marc_links.fulltext
    end
  end
end
