# frozen_string_literal: true

module AccessPanels
  class InCollectionComponent < AccessPanels::Base
    def call
      render AccessPanels::CollectionComponent.with_collection(@document.parent_collections || [], document: @document)
    end
  end
end
