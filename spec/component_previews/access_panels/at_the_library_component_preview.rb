# frozen_string_literal: true

require Rails.root.join("app/models/solr_document")

module AccessPanels
  class AtTheLibraryComponentPreview < Lookbook::Preview
    layout 'lookbook'

    def special_collections
      document = SolrDocument.from_fixture("219330.yml")
      render AccessPanels::AtTheLibraryComponent.new(document: document)
    end

    def sal3
      document = SolrDocument.from_fixture("14059621.yml")
      render AccessPanels::AtTheLibraryComponent.new(document: document)
    end
  end
end
