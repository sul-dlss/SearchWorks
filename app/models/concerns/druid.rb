module Druid
  def druid
    return nil if self[:druid].blank? && purls_from_urls.blank?

    self[:druid] || purls_from_urls.first[/\w+$/]
  end

  private

  def purls_from_urls
    [self[:url_fulltext], self[:url_suppl]].flatten.compact.select do |url|
      url =~ /purl\.stanford\.edu/
    end
  end
end
