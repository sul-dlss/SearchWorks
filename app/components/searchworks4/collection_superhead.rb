# frozen_string_literal: true

module Searchworks4
  class CollectionSuperhead < ViewComponent::Base
    def call
      tag.div 'Collection', class: 'superhead small fw-semibold text-uppercase text-secondary mb-2'
    end
  end
end
