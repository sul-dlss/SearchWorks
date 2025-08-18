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

    def before_render
      with_thumbnail(render_placeholder: true, render_collection_thumbnail_from_member: true)

      super
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
      {
        controller: 'gallery-card',
        action: 'preview:close@document->gallery-card#handlePreviewClosed',
        gallery_card_id_value: @document.id,
        gallery_card_url_value: preview_solr_document_path(@document.id),
        gallery_card_preview_outlet: preview_outlet_selector
      }
    end

    def browse_nearby?
      params[:controller] == "browse" && params[:action] == "nearby"
    end
  end
end
