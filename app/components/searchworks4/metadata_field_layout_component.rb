# frozen_string_literal: true

module Searchworks4
  class MetadataFieldLayoutComponent < ViewComponent::Base
    renders_one :label
    renders_many :values, lambda { |**kwargs, &block|
      tag.dd(**kwargs, &block)
    }

    def render?
      values?
    end
  end
end
