# frozen_string_literal: true

class CollectionFilterQuery < Blacklight::Solr::AbstractFilterQueryBuilder
  def call(filter, _solr_params)
    collection = filter.values.first
    return [["#{filter.key}: #{collection}"], {}] unless /\A([aA]|\d)/.match?(collection)

    collection_id = CollectionHelper.strip_leading_a(collection)
    [["#{filter.key}: (#{collection_id} OR a#{collection_id})"], {}]
  end
end
