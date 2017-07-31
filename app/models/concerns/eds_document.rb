module EdsDocument
  def html_fulltext_available?
    self[:eds_html_fulltext].present?
  end

  def research_starter?
    # TODO: we probably need a better way to determine this
    self['eds_database_name'] == 'Research Starters'
  end

  def eds_restricted?
    # TODO: we probably need a better way to determine this
    self['eds_title'] =~ /^This title is unavailable for guests, please login to see more information./
  end
end
