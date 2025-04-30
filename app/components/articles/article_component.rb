# frozen_string_literal: true

module Articles
  class ArticleComponent < Blacklight::Component
    def initialize(document:)
      @document = document
      super()
    end

    def render?
      !@document.eds_restricted?
    end

    delegate :html_present?, to: :helpers

    attr_reader :document
  end
end
