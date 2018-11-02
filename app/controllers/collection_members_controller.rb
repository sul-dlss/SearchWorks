class CollectionMembersController < ApplicationController
  def show
    @document = SolrDocument.find(show_param)
    respond_to do |format|
      format.json {
        render(
          json: @document.collection_members.with_type(params.permit(:type)[:type]),
          layout: false
        )
      }
    end
  end

  private

  def show_param
    params.require(:id)
  end
end
