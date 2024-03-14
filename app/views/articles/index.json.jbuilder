# frozen_string_literal: true

docs = @presenter.documents.collect do |document|
  link = ArticleFulltextLinkPresenter.new(document:, context: self).links.try(:first) # top priority one only
  composed_title = document['eds_composed_title']
  data = document.to_h # avoids deprecation warning
  data['fulltext_link_html'] = link if link.present?
  data['eds_composed_title'] = italicize_composed_title({ value: Array.wrap(composed_title) }) if composed_title.present?
  data
end
json.response do
  json.docs docs
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
