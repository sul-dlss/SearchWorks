# Search results (CatalogController#index)
xml.item_id(doc[:id])
xml.title(doc["vern_" << document_show_link_field.to_s] ? doc["vern_" << document_show_link_field.to_s] : doc[document_show_link_field.to_s])
xml.pub_date(doc[:pub_date]) if doc[:pub_date]
xml.author(doc[:vern_title_245c_display] ? doc[:vern_title_245c_display] : doc[:title_245c_display] ? doc[:title_245c_display] : nil) if (doc[:title_245c_display] or doc[:vern_title_245c_display])
record_url = catalog_url(doc[:id])
record_url << ".mobile" unless drupal_api?
xml.mobile_record(record_url)
if cover_hash.has_key?(doc[:id])
  xml.image_url{xml.cdata!(cover_hash[doc[:id]][0])}
  xml.image_url_lg{xml.cdata!(cover_hash[doc[:id]][1])}
end
if doc[:format]
  xml.formats{
    doc[:format].each do |format|
      xml.format(format)
    end
  }
end
if doc_is_a_database?(doc)
  if doc["summary_display"]
    xml.summary(truncate(doc["summary_display"].join(" "), :length => 140))
  end
  if doc["url_fulltext"]
    xml.database_url("stanford_only" => index_link_is_stanford_only?(doc,doc["url_fulltext"].first.strip)){xml.cdata!(doc["url_fulltext"].first.strip)}
  end
end
