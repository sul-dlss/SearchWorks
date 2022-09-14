module MarcLinks
  def marc_links
    @marc_links ||= SearchWorks::Links.new(fetch(:marc_links_struct, []).map do |data|
      SearchWorks::Links::Link.new(data.merge(href: SearchWorks::Links.ezproxy_url(data[:href], self) || data[:href]))
    end)
  end
end
