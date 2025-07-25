# frozen_string_literal: true

# This is consumed by Bento
docs = @presenter.documents.collect do |document|
  link = ArticleFulltextLinkPresenter.new(document:, context: self).links.first # top priority one only
  composed_title = document['eds_composed_title']
  data = {
    eds_title: document.eds_title,
    eds_publication_type: document.eds_publication_type,
    eds_source_title: document.eds_source_title,
    eds_abstract: document.eds_abstract,
    eds_authors: document.eds_authors,
    eds_publication_date: document.eds_publication_date
  }
  data['source'] = document.to_h # avoids deprecation warning
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
          json.label item.try(:label) || item.value
          json.value item.value
          json.hits item.hits
        end
      end
    end
  end
  json.pages @presenter.pagination_info
end
