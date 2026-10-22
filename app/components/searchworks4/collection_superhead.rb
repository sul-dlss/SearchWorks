# frozen_string_literal: true

module Searchworks4
  class CollectionSuperhead < ViewComponent::Base
    def call
      tag.div 'Collection', class: 'superhead small fw-semibold text-uppercase fg-secondary mb-3'
    end
  end
end
