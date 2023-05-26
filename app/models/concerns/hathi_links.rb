module HathiLinks
  def hathi_links
    @hathi_links ||= Links.new([ht_link].compact)
  end

  private

  def ht_link
    return unless ht_links.present?

    Links::Link.new(
      link_text: 'Full text via HathiTrust',
      href: ht_links.url,
      fulltext: true,
      stanford_only: !ht_links.publicly_available?,
    )
  end

  def ht_links
    @ht_links ||= HathiTrustLinks.new(self)
  end
end
