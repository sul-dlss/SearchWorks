module CollectionHelper
  def link_to_collection_members(link_text, document, options={})
    link_to(link_text, catalog_index_path(f: { collection: [document[:id]] }))
  end

  def collections_search_params
    { f: { collection_type: ["Digital Collection"] } }
  end
end
