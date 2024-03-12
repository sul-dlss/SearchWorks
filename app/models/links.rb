# frozen_string_literal: true

class Links
  include Enumerable

  PROXY_REGEX = /stanford\.idm\.oclc\.org/

  delegate :each, :present?, :blank?, to: :all

  def initialize(links = [])
    @links = links
  end

  def all
    @links || []
  end

  def fulltext
    all.select(&:fulltext?).reject(&:finding_aid?).reject(&:managed_purl?)
  end

  def supplemental
    all.reject(&:fulltext?).reject(&:finding_aid?).reject(&:managed_purl?)
  end

  def finding_aid
    all.select(&:finding_aid?)
  end

  def sfx
    all.select(&:sfx?)
  end

  # sort managed purls by the sort key from the 856$x (with empty values last), then by link text (again with empty values last)
  def managed_purls
    all.select(&:managed_purl?).sort_by { |x| [x.sort.present? ? 0 : 1, x.sort, x.text.present? ? 0 : 1, x.text] }
  end

  def ill
    all.select(&:ill?)
  end
end
