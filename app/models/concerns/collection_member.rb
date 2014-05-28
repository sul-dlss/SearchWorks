module CollectionMember
  def is_a_collection_member?
    self[:collection] and self[:collection] != ['sirsi']
  end

  def parent_collections
    return nil unless is_a_collection_member?
    @parent_collections ||= Blacklight.solr.select(
      params: { fq: parent_collection_params }
    )['response']['docs'].map do |doc|
      SolrDocument.new(doc)
    end
  end

  private
  def parent_collection_params
    self["collection"].map do |collection_id|
      "id:#{collection_id}"
    end.join(" OR ")
  end
end
