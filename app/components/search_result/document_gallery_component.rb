# frozen_string_literal: true

module SearchResult
  class DocumentGalleryComponent < SearchResult::DocumentComponent
    def preview_container_dom_class
      "preview-container-#{document.id}"
    end

    def preview_data_attrs(preview_type, id, target)
      "data-behavior=\"#{preview_type}\" data-preview-url=\"#{preview_path(id)}\" data-preview-target=\"#{target}\"".html_safe
    end
  end
end
