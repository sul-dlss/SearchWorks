module Druid
  def druid
    return nil unless purls_from_urls.present?
    purls_from_urls.first[/\w+$/]
  end
  private
  def purls_from_urls
    [self[:url_fulltext], self[:url_suppl]].flatten.compact.select do |url|
      url =~ /purl\.stanford\.edu/
    end
  end
end
