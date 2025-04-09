# frozen_string_literal: true

module DocumentLinks
  include MarcLinks
  include AccessPanelLinks
  include EdsLinks

  def preferred_online_links
    sfx_links || marc_fulltext_links || eds_links&.fulltext || []
  end

  private

  def sfx_links
    access_panel_links.sfx.presence
  end

  def marc_fulltext_links
    marc_links.fulltext if marc_links&.fulltext.present?
  end
end
