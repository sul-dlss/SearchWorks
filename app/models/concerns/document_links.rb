module DocumentLinks
  include MarcLinks
  include IndexLinks
  include EdsLinks

  def preferred_online_links
    sfx_links || marc_fulltext_links || eds_links&.fulltext || []
  end

  private

  def sfx_links
    index_links.sfx if index_links.sfx.present?
  end

  def marc_fulltext_links
    marc_links.fulltext if marc_links&.fulltext.present?
  end
end
