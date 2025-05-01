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

    def bound_with_title(document)
      (instance_id == document.id ? tag.em('Same title') : link_to(document['title_full_display'], solr_document_path(document.id), data: { turbo: false }))
    end
  end
end
