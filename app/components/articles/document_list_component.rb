# frozen_string_literal: true

# Overriding the Blacklight component to bring the thumbnail up into the main section.
module Articles
  class DocumentListComponent < Blacklight::DocumentComponent
    attr_reader :document, :counter

    def actions
      helpers.render_index_doc_actions document, wrapping_class: 'index-document-functions col'
    end

    delegate :eds_restricted?, to: :document

    def classes
      original = super
      original.push('eds-restricted') if eds_restricted?
      original
    end

    def doc_presenter
      @doc_presenter ||= helpers.document_presenter(document)
    end

    def resource_icon
      helpers.render_articles_format_icon(@document.eds_publication_type || @document.eds_document_type)
    end
  end
end
