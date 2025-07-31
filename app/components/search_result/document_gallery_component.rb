# frozen_string_literal: true

module SearchResult
  class DocumentGalleryComponent < Blacklight::DocumentComponent
    attr_reader :document, :counter

    def initialize(document:, document_counter: 0, starting_document: nil, preview_id: nil, **)
      super(document: document, document_counter: document_counter, **)

      @starting_document = starting_document
      @preview_id = preview_id
    end

    def resource_icon
      helpers.render_resource_icon(presenter.formats)
    end

    def actions
      helpers.render_index_doc_actions document, wrapping_class: 'index-document-functions col'
    end

    def preview_container_dom_class
      "preview-container-#{document.id}"
    end

    def preview_outlet_selector
      if @preview_id
        "##{@preview_id}"
      else
        ".#{preview_container_dom_class}"
      end
    end

    def classes
      super - ['document'] + %w[border gallery-document] + [('current-document' if @starting_document && document.id == @starting_document.id)].compact
    end

    def data
      {
        document_id: @document.id,
        document_counter: @counter
      }.merge(stimulus_attributes)
    end

    def stimulus_attributes
      if browse_nearby?
        {
          controller: 'preview-embed-browse',
          action: 'preview:close@document->preview-embed-browse#handlePreviewClosed',
          preview_embed_browse_id_value: @document.id,
          preview_embed_browse_url_value: preview_path(@document.id),
          preview_embed_browse_preview_embed_browse_outlet: '.gallery-document',
          preview_embed_browse_preview_outlet: preview_outlet_selector,
          preview_embed_browse_actions_selector_value: ".document-actions"
        }
      else
        {
          controller: 'gallery-preview',
          gallery_preview_id_value: @document.id,
          gallery_preview_url_value: preview_path(@document.id),
          gallery_preview_gallery_preview_outlet: '.gallery-document',
          gallery_preview_preview_selector_value: ".#{preview_container_dom_class}",
          gallery_preview_actions_selector_value: ".document-actions"
        }
      end
    end

    def browse_nearby?
      params[:controller] == "browse" && params[:action] == "nearby"
    end
  end
end
