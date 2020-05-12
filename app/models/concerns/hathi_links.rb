module HathiLinks
  def hathi_links
    @hathi_links ||= HathiLinks::Processor.new(self)
  end

  class Processor < SearchWorks::Links
    def all
      return [] unless ht_links.present?

      Array.wrap(
        SearchWorks::Links::Link.new(
          html: "<a href=\"#{ht_links.url}\">Full text via HathiTrust</a>",
          text: 'Full text via HathiTrust',
          href: ht_links.url,
          fulltext: true,
          stanford_only: !ht_links.publicly_available?,
        )
      )
    end

    private

    def ht_links
      @ht_links ||= HathiTrustLinks.new(@document)
    end
  end
end
