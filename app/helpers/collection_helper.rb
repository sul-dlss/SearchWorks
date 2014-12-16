module CollectionHelper
  def link_to_collection_members(link_text, document, options={})
    link_to(link_text, catalog_index_path(f: { collection: [document[:id]] }))
  end

  def collection_members_enumeration(document)
    if document.collection_members.present?
      "#{pluralize(document.collection_members.total, 'item')} online"
    end
  end

  def collections_search_params
    { f: { collection_type: ["Digital Collection"] } }
  end

  def collection_breadcrumb_value(collection_id)
    if @document_list.present? && @document_list.first.index_parent_collections.present?
      collection = @document_list.first.index_parent_collections.find do |coll|
        coll[:id] == collection_id
      end
      return presenter(collection).document_heading if collection.present?
    end
    collection_id
  end

  def add_purl_embed_header(document)
    content_for(:head) do
      ['json', 'xml'].map do |format|
        "<link rel='alternate' type='application/#{format}+oembed' title='#{presenter(@document).document_heading}' href='#{Settings.PURL_EMBED_RESOURCE}embed?url=#{Settings.PURL_EMBED_RESOURCE}#{@document.druid}&format=#{format}' />"
      end.join.html_safe
    end
  end

end
