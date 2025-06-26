# frozen_string_literal: true

module AccessPanels
  class SimilarHoldingsComponent < ViewComponent::Base
    def initialize(document:)
      @id = document.id
      super()
    end

    def call
      helpers.turbo_frame_tag 'similar_holdings', src: "https://semantic-search-demo.stanford.edu/similar/#{@id}"
    end
  end
end
