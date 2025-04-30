# frozen_string_literal: true

# Overriding the Blacklight component to bring the thumbnail up into the main section.
module Articles
  class DocumentComponent < Blacklight::DocumentComponent
    # NOTE: ideally this would override the metadata slot in Blacklight, but I'm not sure how to do that.
    def document_metadata
      render Articles::ArticleComponent.new(presenter: @presenter)
    end
  end
end
