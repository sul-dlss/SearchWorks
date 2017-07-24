module EdsDocument
  def html_fulltext_available?
    self[:eds_html_fulltext].present?
  end
end
