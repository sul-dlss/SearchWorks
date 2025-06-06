# frozen_string_literal: true

module SearchResult
  class DocumentGalleryComponent < SearchResult::DocumentComponent
    def preview_container_dom_class
      "preview-container-#{document.id}"
    end

    def classes
      super - ['document'] + ['gallery-document']
    end

    def data
      {
        doc_id: @document.id,
        controller: 'preview-embed-browse',
        preview_embed_browse_id_value: @document.id,
        preview_embed_browse_url_value: preview_path(@document.id),
        preview_embed_browse_preview_embed_browse_outlet: '.gallery-document',
        preview_embed_browse_preview_selector_value: ".#{preview_container_dom_class}"
      }
    end
  end
end
