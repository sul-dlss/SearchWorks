docs = @presenter.documents.collect do |document|
  link = ArticleFulltextLinkPresenter.new(document: document, context: self).links.try(:first) # top priority one only
  composed_title = document['eds_composed_title']
  data = document.to_h # avoids deprecation warning
  data['fulltext_link_html'] = link if link.present?
  data['eds_composed_title'] = italicize_composed_title({ value: Array.wrap(composed_title) }) if composed_title.present?
  data
end
json.response do
  json.docs docs
  json.facets @presenter.search_facets_as_json
  json.pages @presenter.pagination_info
end
