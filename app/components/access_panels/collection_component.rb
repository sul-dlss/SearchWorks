module AccessPanels
  class CollectionComponent < AccessPanels::Base
    with_collection_parameter :collection

    def initialize(collection:, document:)
      super(document: document)

      @collection = collection
    end
  end
end