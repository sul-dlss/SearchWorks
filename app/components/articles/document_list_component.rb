# frozen_string_literal: true

# Overriding the Blacklight component to bring the thumbnail up into the main section.
module Articles
  class DocumentListComponent < Blacklight::DocumentComponent
    attr_reader :document, :counter

    def actions
      helpers.render_index_doc_actions document, wrapping_class: 'index-document-functions'
    end

    delegate :eds_restricted?, to: :document

    def classes
      original = super
      original.push('eds-restricted') if eds_restricted?
      original
    end

    # NOTE: ideally this would override the metadata slot in Blacklight, but I'm not sure how to do that.
    def document_metadata
      render Articles::MetadataComponent.new(document: @document)
    end
  end
end
