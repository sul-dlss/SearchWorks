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
      }.tap do |h|
        if browse_nearby?
          h[:controller] = 'preview-embed-browse'
          h[:preview_embed_browse_url_value] = preview_path(@document.id)
          h[:preview_embed_browse_preview_selector_value] = ".#{preview_container_dom_class}"
        else
          h[:behavior] = 'preview-gallery'
          h[:preview_target] = ".#{preview_container_dom_class}"
          h[:preview_url] = preview_path(@document.id)
        end
      end
    end

    def browse_nearby?
      params[:controller] == "browse" && params[:action] == "nearby"
    end
  end
end
