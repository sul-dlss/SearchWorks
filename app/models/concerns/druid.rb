module Druid
  def druid
    return nil if self[:druid].blank? && purls_from_urls.blank?

    self[:druid] || purls_from_urls.first[/\w+$/]
  end

  private

  def purls_from_urls
    [index_links.fulltext, index_links.supplemental].flatten.compact.map(&:href).select do |href|
      /purl\.stanford\.edu/.match?(href)
    end
  end
end
