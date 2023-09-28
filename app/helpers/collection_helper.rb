module CollectionHelper
  def link_to_collection_members(link_text, document, options = {})
    link_to(link_text, search_catalog_path(f: { collection: [document[:id]] }), options)
  end

  def collection_members_path(document, options = {})
    search_catalog_path(f: { collection: [document[:id]] })
  end

  def collection_members_enumeration(document)
    if document.collection_members.present?
      "#{pluralize(document.collection_members.total, 'item')} online"
    end
  end

  def text_for_inner_members_link(document)
    return if document.collection_members.blank?

    items_count_text = pluralize(document.collection_members.total, 'digital item')
    "Explore this collection <strong>(#{items_count_text})</strong>".html_safe
  end

  def collections_search_params
    { f: { collection_type: ["Digital Collection"] } }
  end

  def collection_breadcrumb_value(collection_id)
    if @response.documents.first&.index_parent_collections.present?
      collection = @response.documents.first.index_parent_collections.find do |coll|
        # strip leading 'a' from collection catkeys
        coll[:id] == collection_id.sub(/^a(\d+)$/, '\1')
      end
      return document_presenter(collection).heading if collection.present?
    end
    collection_id
  end

  def add_purl_embed_header(document)
    content_for(:head) do
      ['json', 'xml'].map do |format|
        "<link rel='alternate' type='application/#{format}+oembed' title='#{document_presenter(@document).heading}' href='#{Settings.PURL_EMBED_RESOURCE}embed?url=#{Settings.PURL_EMBED_RESOURCE}#{@document.druid}&format=#{format}' />"
      end.join.html_safe
    end
  end
end
