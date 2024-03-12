# frozen_string_literal: true

module AdvancedSearchParamsMapping
  extend ActiveSupport::Concern
  included do
    if self.respond_to?(:before_action)
      before_action :map_advanced_search_params, only: :index
    end
  end

  private

  def map_advanced_search_params
    return unless params.slice(*advanced_search_legacy_field_mapping.keys).present?

    params[:clause] ||= {}

    advanced_search_legacy_field_mapping.each do |field, new_field|
      next unless params[field]

      params[:clause][field] = { query: params[field], field: new_field }
      params.delete(field)
    end
  end

  # These were the old, old search fields used by advanced search (before Searchworks 3.0)
  # https://github.com/sul-dlss/SearchWorks/pull/792/files
  def advanced_search_legacy_field_mapping
    {
      author: 'search_author',
      title: 'search_title',
      subject: 'subject_terms',
      description: 'search',
      pub_info: 'pub_search',
      number: 'isbn_search'
    }
  end
end
