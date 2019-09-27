xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.urlset(
  'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xsi:schemaLocation' => 'http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd',
  'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9'
) do
  @solr_response['response']['docs'].each do |doc|
    xml.url do
      xml.loc(solr_document_url(doc['id']))
      xml.lastmod(doc['last_updated'])
    end
  end
end
