# frozen_string_literal: true

module Record
  class ArticleComponent < Blacklight::Component
    def initialize(document:)
      @document = document
      super()
    end

    delegate :html_present?, to: :helpers

    attr_reader :document
  end
end
