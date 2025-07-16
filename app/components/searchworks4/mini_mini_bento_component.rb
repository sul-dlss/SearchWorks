# frozen_string_literal: true

module Searchworks4
  class MiniMiniBentoComponent < ViewComponent::Base
    delegate :search_state, to: :helpers

    def initialize(current_context:)
      @current_context = current_context
      super
    end

    def render?
      search_state.query_param.present?
    end

    def name
      @current_context == 'articles' ? 'Catalog' : 'Articles+'
    end

    def url
      if @current_context == 'articles'
        search_catalog_path(q: search_state.query_param)
      else
        articles_path q: search_state.query_param, f: { eds_search_limiters_facet: ['Direct access to full text'] }
      end
    end
  end
end
