xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.sitemapindex(
  'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xsi:schemaLocation' => 'http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd',
  'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9'
) do
  @access_list.each do |id|
    xml.sitemap do
      xml.loc(sitemap_url(id, format: :xml))
    end
  end
end
