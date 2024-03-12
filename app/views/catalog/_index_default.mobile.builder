# frozen_string_literal: true

# Search results (CatalogController#index)
xml.item_id(doc[:id])
xml.title(doc["vern_" << document_show_link_field.to_s] ? doc["vern_" << document_show_link_field.to_s] : doc[document_show_link_field.to_s])
xml.pub_date(doc[:pub_date]) if doc[:pub_date]
xml.author(doc[:vern_title_245c_display] ? doc[:vern_title_245c_display] : doc[:title_245c_display] ? doc[:title_245c_display] : nil) if doc[:title_245c_display] or doc[:vern_title_245c_display]
record_url = solr_document_url(doc[:id])
record_url << ".mobile" unless drupal_api?
xml.mobile_record(record_url)
if cover_hash.has_key?(doc[:id])
  xml.image_url { xml.cdata!(cover_hash[doc[:id]][0]) }
  xml.image_url_lg { xml.cdata!(cover_hash[doc[:id]][1]) }
end
if doc[:format]
  xml.formats {
    doc[:format].each do |format|
      xml.format(format)
    end
  }
end
if doc_is_a_database?(doc)
  if doc["summary_display"]
    xml.summary(truncate(doc["summary_display"].join(" "), length: 140))
  end
  if doc.index_links.fulltext.any?
    xml.database_url("stanford_only" => doc.index_links.fulltext.first.stanford_only?) { xml.cdata!(doc.index_links.fulltext.first.href) }
  end
end
