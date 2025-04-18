# frozen_string_literal: true

module Record
  class BoundWithChildrenComponent < ViewComponent::Base
    def initialize(bound_with_children:, item_id:, instance_id:)
      super
      @bound_with_children = bound_with_children
      @item_id = item_id
      @instance_id = instance_id
    end

    attr_reader :bound_with_children, :item_id, :instance_id
  end
end
