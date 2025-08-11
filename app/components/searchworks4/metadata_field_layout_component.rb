# frozen_string_literal: true

module Searchworks4
  class MetadataFieldLayoutComponent < ViewComponent::Base
    renders_one :label
    renders_many :values, lambda { |**kwargs, &block|
      tag.dd(**kwargs, &block)
    }

    def initialize(classes: ['my-2'])
      @classes = classes
      super()
    end

    def render?
      values?
    end
  end
end
