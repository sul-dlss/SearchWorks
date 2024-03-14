# frozen_string_literal: true

module AccessPanels
  class CollectionComponent < AccessPanels::Base
    with_collection_parameter :collection

    def initialize(collection:, document:)
      super(document:)

      @collection = collection
    end
  end
end
