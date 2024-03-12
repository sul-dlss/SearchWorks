# frozen_string_literal: true

module CollectionAccessPointHelper
  def get_collection
    if @response.docs.first.present?
      @parent = SolrDocument.new(@response.docs.first.to_h).parent_collections.find { |c| c.id == params[:f][:collection][0] }
    end
  end
end
