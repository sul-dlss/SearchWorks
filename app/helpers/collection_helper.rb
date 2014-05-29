module CollectionHelper
  def link_to_collection_members(link_text, document, options={})
    link_to(link_text, catalog_index_path(f: { collection: [document[:id]] }))
  end
end
