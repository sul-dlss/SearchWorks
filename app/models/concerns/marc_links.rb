# marc_links returns a Links::Link object for each :marc_link_struct value.
# marc_links are displayed along with other record metadata and have the default
# link_text values vs. links created in the IndexLinks module that modifies the link_text values.
module MarcLinks
  def marc_links
    @marc_links ||= Links.new(fetch(:marc_links_struct, []).map do |data|
      Links::Link.new(data.merge(href: Links.ezproxy_url(data[:href], self) || data[:href]))
    end)
  end
end
