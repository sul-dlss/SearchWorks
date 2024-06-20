class BoundWithChildrenController < ApplicationController
  include Blacklight::Configurable
  include Blacklight::Searchable
  copy_blacklight_config_from(CatalogController)

  class Builder
    def initialize(item_id)
      @item_id = item_id
    end

    def reverse_merge(extra)
      extra.merge(q: "bound_with_parent_item_ids_ssim:#{@item_id}", facet: false)
    end
  end

  def index
    @id = params.require(:id)
    @item_id = params.require(:item_id)
    builder = Builder.new(@item_id)
    search = search_service.repository.search(builder)
    @bound_with_children = search.docs
  end
end
