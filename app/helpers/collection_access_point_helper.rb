module CollectionAccessPointHelper
  def get_collection
    if @response.docs.first.present?
      @parent = SolrDocument.new(@response.docs.first).parent_collections.find { |c| c.id == params[:f][:collection][0] }
    end
  end
end
