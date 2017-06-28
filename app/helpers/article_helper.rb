module ArticleHelper
  def article_search?
    controller_name == 'article'
  end

  def search_session
    {} # TODO: placeholder
  end

  def current_search_session
    {} # TODO: placeholder
  end

  def doi_link(options = {})
    doi = options[:value].try(:first)
    return if doi.blank?
    url = 'https://doi.org/' + doi.to_s
    link_to(doi, url)
  end

  def article_restricted?(document)
    # TODO: we probably need a better way to determine this
    document['eds_title'] =~ /^This title is unavailable for guests, please login to see more information./
  end
end
