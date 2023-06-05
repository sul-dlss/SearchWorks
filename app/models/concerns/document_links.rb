module DocumentLinks
  include MarcLinks
  include IndexLinks
  include EdsLinks
  include HathiLinks

  def preferred_online_links
    sfx_links || marc_fulltext_links || non_stanford_hathi_links || eds_links&.fulltext || []
  end

  private

  def sfx_links
    index_links.sfx if index_links.sfx.present?
  end

  def marc_fulltext_links
    marc_links.fulltext if marc_links&.fulltext.present?
  end

  def non_stanford_hathi_links
    non_stanford_links = hathi_links.all.reject(&:stanford_only?)

    return unless non_stanford_links.any?

    non_stanford_links
  end

end
