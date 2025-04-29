# frozen_string_literal: true

module SearchResult
  class IndexBriefComponent < SearchResult::DocumentComponent
    attr_reader :document, :counter

    def resource_icon
      helpers.render_resource_icon(presenter.formats)
    end

    def actions
      helpers.render_index_doc_actions document, wrapping_class: 'index-document-functions'
    end
  end
end
