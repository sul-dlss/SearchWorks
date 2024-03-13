# frozen_string_literal: true

module CollectionHelper
  def self.strip_leading_a(collection_id)
    collection_id.sub(/^a(\d+)$/, '\1')
  end

  def link_to_collection_members(link_text, document, options = {})
    link_to(link_text, collection_members_path(document), options)
  end

  def collection_members_path(document, options = {})
    search_catalog_path(f: { collection: [document.collection_id] })
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
        coll[:id] == CollectionHelper.strip_leading_a(collection_id)
      end
      return document_presenter(collection).heading if collection.present?
    end
    collection_id
  end

  def add_purl_embed_header(document)
    content_for(:head) do
      ['json', 'xml'].map do |format|
        embed_url = "#{Settings.PURL_EMBED_RESOURCE}embed?url=#{Settings.PURL_EMBED_RESOURCE}#{document.druid}&format=#{format}"
        auto_discovery_link_tag :oembed, embed_url, type: "application/#{format}+oembed", title: document_presenter(document).heading
      end.join.html_safe
    end
  end
end
