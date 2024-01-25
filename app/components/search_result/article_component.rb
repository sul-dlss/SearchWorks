# frozen_string_literal: true

module SearchResult
  class ArticleComponent < Blacklight::Component
    def initialize(document:)
      @document = document

      super()
    end

    def doc_presenter
      @doc_presenter ||= helpers.document_presenter(document)
    end

    attr_reader :document
  end
end
