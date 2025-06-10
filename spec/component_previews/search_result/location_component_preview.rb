# frozen_string_literal: true

require Rails.root.join("app/models/solr_document")

module SearchResult
  class LocationComponentPreview < Lookbook::Preview
    def multiple_locations
      document = SolrDocument.from_fixture("219330.yml")
      library = document.holdings.libraries.first

      render SearchResult::LocationComponent.new(library: library, document: document)
    end
  end
end
