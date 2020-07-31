# Overridden from Blacklight to inject content into documents
json.response do
  json.docs augment_solr_document_json_response(@presenter.documents)
  json.facets @presenter.search_facets_as_json
  json.pages @presenter.pagination_info
end
