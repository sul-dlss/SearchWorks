# frozen_string_literal: true

# Overridden from Blacklight to inject content into documents
json.response do
  json.docs augment_solr_document_json_response(@presenter.documents)
  json.facets do
    json.array! @presenter.search_facets do |facet|
      facet_config = facet_configuration_for_field(facet.name)
      json.label facet_field_label(facet_config.key)
      json.name facet_config.key
      json.items do
        json.array! facet.items do |item|
          json.label item.label || item.value
          json.value item.value
          json.hits item.hits
        end
      end
    end
  end
  json.pages @presenter.pagination_info
end
