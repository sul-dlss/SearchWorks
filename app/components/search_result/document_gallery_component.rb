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
        document_counter: @counter
      }.merge(stimulus_attributes)
    end

    def stimulus_attributes
      if browse_nearby?
        {
          controller: 'preview-embed-browse',
          preview_embed_browse_url_value: preview_path(@document.id),
          preview_embed_browse_preview_selector_value: ".#{preview_container_dom_class}"
        }
      else
        {
          controller: 'gallery-preview',
          gallery_preview_url_value: preview_path(@document.id),
          gallery_preview_preview_selector_value: ".#{preview_container_dom_class}"
        }
      end
    end

    def browse_nearby?
      params[:controller] == "browse" && params[:action] == "nearby"
    end
  end
end
