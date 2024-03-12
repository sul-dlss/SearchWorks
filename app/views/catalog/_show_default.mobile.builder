# frozen_string_literal: true

# Record View (CatalogController#show)
xml.item_id(doc[:id])
xml.full_title(doc[:title_full_display])
xml.title(doc[:title_display])
unless get_authors_for_mobile(doc).nil?
  xml.authors {
    get_authors_for_mobile(doc).each do |author|
      xml.author(author)
    end
  }
end
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
if doc[:isbn_display]
  xml.isbns {
    doc[:isbn_display].each do |isbn|
      xml.isbn(isbn)
    end
  }
end

summary = doc.fetch(:summary_struct, []).first
unless summary.nil?
  summary_text = []
  summary[:fields].each do |field|
    if field[:vernacular].nil?
      summary_text << field[:field]
    else
      summary_text << field[:vernacular]
    end
  end
  xml.summary(summary_text.join(" "))
end

toc = doc.fetch(:toc_struct, []).first
unless toc.nil?
  xml.contents {
    unless toc[:fields].nil?
      toc[:fields].flatten.each do |content|
        xml.content(content)
      end
    end
    unless toc[:vernacular].nil?
      toc[:vernacular].flatten.each do |content|
        xml.content(content)
      end
    end
    unless toc[:unmatched_vernacular].nil?
      toc[:unmatched_vernacular].flatten.each do |content|
        xml.content(content)
      end
    end
  }
end

if doc.respond_to?(:to_marc)
  xml.imprint(get_imprint_for_mobile(doc.to_marc)) unless get_imprint_for_mobile(doc.to_marc).nil?
end
# index_parent_collections
if @document.index_parent_collections.present?
  @document.index_parent_collections.each do |collection|
    xml.collection {
      xml.id(collection[:id])
      xml.title(collection[:title_display])
    }
  end
end
urls = get_urls_for_mobile(doc)
unless urls.nil?
  xml.urls {
    urls.each do |url|
      xml.url("label" => url[:label]) { xml.cdata!(url[:link]) }
    end
  }
end
xml.record_url('label' => "View Item in SearchWorks") { xml.cdata!(url_for controller: 'catalog', action: 'show', id: doc[:id], only_path: false) }
xml.holdings {
  doc.holdings.libraries.each do |library|
    xml.library('name' => library.name) {
      library.locations.each do |location|
        xml.location('name' => location.name) {
          location.items.each do |item|
            xml.item {
              xml.callnumber(item.callnumber)
            }
          end
        }
      end
    }
  end
}
