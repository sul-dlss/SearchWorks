# frozen_string_literal: true

module Searchworks4
  class CollectionInfoComponent < ViewComponent::Base
    def initialize(collection:)
      @collection = collection
      super
    end

    attr_reader :collection

    def render?
      collection.present?
    end
  end
end
