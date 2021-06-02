module HathiLinks
  def hathi_links
    @hathi_links ||= SearchWorks::Links.new([ht_link].compact)
  end

  private

  def ht_link
    return unless ht_links.present?

    SearchWorks::Links::Link.new(
      html: "<a href=\"#{ht_links.url}\">Full text via HathiTrust</a>",
      text: 'Full text via HathiTrust',
      href: ht_links.url,
      fulltext: true,
      stanford_only: !ht_links.publicly_available?,
    )
  end

  def ht_links
    @ht_links ||= HathiTrustLinks.new(self)
  end
end
