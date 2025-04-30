# frozen_string_literal: true

module Articles
  class DocumentBriefComponent < Articles::DocumentListComponent
    def initialize(*, document:, document_counter: nil, **)
      super

      @component = 'div'
      @classes = ['brief-document', 'container-fluid']
    end

    def classes
      super - ['document']
    end
  end
end
