module EdsDocument

  def article_restricted?
    # TODO: we probably need a better way to determine this
    self[:eds_title] =~ /^This title is unavailable for guests, please login to see more information./
  end

  def html_fulltext_available?
    self[:eds_html_fulltext].present?
  end
end
