# frozen_string_literal: true

module Record
  class ArticleComponent < Blacklight::Component
    def initialize(document:)
      @document = document
      super()
    end

    attr_reader :document
  end
end
