# frozen_string_literal: true

module CollectionHelper
  def self.strip_leading_a(collection_id)
    collection_id.sub(/^a(\d+)$/, '\1')
  end

  def collection_members_path(document, options = {})
    search_catalog_path(f: { collection: [document.prefixed_id] })
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
      tag.link(rel: 'canonical', href: "#{Settings.PURL_EMBED_RESOURCE}#{document.druid}")
    end
  end
end
