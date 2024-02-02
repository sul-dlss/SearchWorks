##
# A mixin to add set member behavior to SolrDocuments.
# Items that are in a set identify their set membership
# by indexing their set's identifier in the set field.
module SolrSet
  def set_member?
    self[:set].present?
  end

  def parent_sets
    return unless set_member?

    @parent_sets ||= set_document_list.map do |doc|
      SolrDocument.new(doc)
    end
  end

  # Used for generating simple title links to the parent sets w/o making a Solr request
  def index_parent_sets
    return unless set_member? && self[:set_with_title].present?

    @index_parent_sets ||= self[:set_with_title].map do |set_with_title|
      id, title = set_with_title.split('-|-').map(&:strip)
      SolrDocument.new(id:, title_display: title)
    end
  end

  private

  def set_document_list
    @document_list ||= Blacklight.default_index.connection.select(set_solr_params)['response']['docs']
  end

  def set_solr_params
    ids = self['set'].map do |set_id|
      "id:#{CollectionHelper.strip_leading_a(set_id)}"
    end.join(' OR ')
    { params: { fq: ids } }
  end
end
