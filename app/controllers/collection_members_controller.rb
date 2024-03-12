# frozen_string_literal: true

class CollectionMembersController < ApplicationController
  def show
    @document = SolrDocument.find(collection_id)
    respond_to do |format|
      format.json {
        render(
          json: @document.collection_members.with_type(collection_params[:type]),
          layout: false
        )
      }
    end
  end

  private

  def collection_params
    params.permit(:id, :type, :format)
  end

  def collection_id
    collection_params.require(:id)
  end
end
