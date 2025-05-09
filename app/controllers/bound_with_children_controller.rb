# frozen_string_literal: true

class BoundWithChildrenController < ApplicationController
  include Blacklight::Configurable
  include Blacklight::Searchable
  copy_blacklight_config_from(CatalogController)

  configure_blacklight do |config|
    config.default_solr_params = { facet: false, rows: 100, qt: 'search' }
    config.search_state_fields = %i[id item_id]
    config.facet_fields.clear
  end

  def modal
    @id = params.require(:id)
    @item_id = params.require(:item_id)
    @response = search_results(@item_id)
    @bound_with_children = filtered_children(@response.docs)
    @bound_with_parent = @bound_with_children.first&.bound_with_parent
  end

  def index
    @id = params.require(:id)
    @item_id = params.require(:item_id)
    limit = params[:limit] ? params[:limit].to_i : 3
    @response = search_results(@item_id, limit: limit)
    @bound_with_children = filtered_children(@response.docs)
    @bound_with_parent = @bound_with_children.first&.bound_with_parent
  end

  private

  def search_results(item_id, limit: 100)
    search_service.search_results do |builder|
      builder.where(bound_with_parent_item_ids_ssim: item_id).rows(limit)
    end
  end

  def filtered_children(bound_with_children)
    bound_with_children.flat_map do |child|
      child.items.select { |item| item.id == @item_id && !item.bound_with_principal? }
    end.sort_by(&:full_shelfkey)
  end
end
