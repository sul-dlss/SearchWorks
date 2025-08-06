# frozen_string_literal: true

module DocumentLinks
  include MarcLinks

  def preferred_online_links
    marc_links&.fulltext || []
  end

  def has_finding_aid?
    finding_aid.first&.href.present?
  end

  def preferred_finding_aid
    marc_links&.finding_aid&.first
  end
end
