# frozen_string_literal: true

module DocumentLinks
  include MarcLinks
  include EdsLinks

  def preferred_online_links
    sfx_links || marc_fulltext_links || eds_links&.fulltext || []
  end

  def has_finding_aid?
    finding_aid.first&.href.present?
  end

  def finding_aid
    marc_links&.finding_aid
  end

  private

  def sfx_links
    marc_links.sfx.presence
  end

  def marc_fulltext_links
    marc_links.fulltext if marc_links&.fulltext.present?
  end
end
