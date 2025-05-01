# frozen_string_literal: true

class BoundWithChildrenController < ApplicationController
  include Blacklight::Configurable
  include Blacklight::Searchable
  copy_blacklight_config_from(CatalogController)

  class Builder
    def initialize(item_id, limit)
      @item_id = item_id
      @limit = limit
    end

    def reverse_merge(extra)
      extra.merge(q: "bound_with_parent_item_ids_ssim:#{@item_id}", facet: false, rows: @limit)
    end
  end

  def modal
    @id = params.require(:id)
    @item_id = params.require(:item_id)
    builder = Builder.new(@item_id, 100)
    search = search_service.repository.search(builder)
    @bound_with_children = filtered_children(search.docs)
    @bound_with_parent = @bound_with_children.first.bound_with_parent
  end

  def index
    @id = params.require(:id)
    @item_id = params.require(:item_id)
    @limit = params[:limit] ? params[:limit].to_i : 3
    builder = Builder.new(@item_id, @limit)
    search = search_service.repository.search(builder)
    @number_of_results = search.response['numFound']
    @bound_with_children = filtered_children(search.docs)
    @bound_with_parent = @bound_with_children.first.bound_with_parent
  end

  def filtered_children(bound_with_children)
    @filtered_children = bound_with_children.flat_map do |child|
      child.items.select { |item| item.id == @item_id && !item.bound_with_principal? }
    end
  end
end
