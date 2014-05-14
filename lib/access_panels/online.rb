class Online < AccessPanel
  delegate :present?, to: :links
  def links
    if @document.marc_links.present?
      @document.marc_links.fulltext.map do |link|
        [link.before, "<a title='#{link.after}' href='#{link.href}'>#{link.text}</a>"].compact.join(' ')
      end
    end
  end
end
