module CollectionHelper
  def link_to_collection_members(link_text, document, options={})
    link_to(link_text, catalog_index_path(f: { collection: [document[:id]] }))
  end

  def collection_members_enumeration(document)
    if document.collection_members.present?
      "1 - #{document.collection_members.length} of #{pluralize(document.collection_members.total, 'item')} online"
    end
  end

  def collections_search_params
    { f: { collection_type: ["Digital Collection"] } }
  end
end
