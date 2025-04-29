# frozen_string_literal: true

module SearchResult
  class DocumentGalleryComponent < SearchResult::DocumentComponent
    def preview_container_dom_class
      "preview-container-#{document.id}"
    end
  end
end
