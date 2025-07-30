# frozen_string_literal: true

class CollectionMembersController < ApplicationController
  def show
    @document = SolrDocument.find(collection_id)
  end

  private

  def collection_id
    params.expect(:id)
  end
end
