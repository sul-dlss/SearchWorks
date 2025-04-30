# frozen_string_literal: true

module DocumentLinks
  include MarcLinks

  def preferred_online_links
    sfx_links || marc_fulltext_links || []
  end

  def has_finding_aid?
    finding_aid.first&.href.present?
  end

  def finding_aid
    marc_links&.finding_aid
  end

  def preferred_finding_aid
    finding_aid&.first
  end

  def additional_finding_aids?
    has_finding_aid? && finding_aid.length > 1
  end

  def additional_finding_aids
    return nil unless additional_finding_aids?

    finding_aid.drop(1)
  end

  private

  def sfx_links
    marc_links.sfx.presence
  end

  def marc_fulltext_links
    marc_links.fulltext if marc_links&.fulltext.present?
  end
end
