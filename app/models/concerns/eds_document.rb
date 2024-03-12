# frozen_string_literal: true

module EdsDocument
  def html_fulltext?
    self['eds_html_fulltext_available'] == true
  end

  def research_starter?
    # TODO: we probably need a better way to determine this
    self['eds_database_name'] == 'Research Starters'
  end

  def eds_restricted?
    # TODO: we probably need a better way to determine this
    self['eds_title'] =~ ::SolrDocument::EDS_RESTRICTED_PATTERN
  end

  def eds?
    self[:eds_title].present?
  end
end
