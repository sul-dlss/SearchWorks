# frozen_string_literal: true

module Blacklight
  class StartOverButtonComponent < Blacklight::Component
    def call
      link_to("<i class='fa fa-fast-backward'></i> <span class='d-none d-sm-inline'>#{label}</span></a>".html_safe, start_over_path, class: 'btn btn-primary btn-reset')
    end

    private

    def label
      if controller.is_a? ArticlesController
        'Articles+ start'
      else
        'Catalog start'
      end
    end

    ##
    # Get the path to the search action with any parameters (e.g. view type)
    # that should be persisted across search sessions.
    def start_over_path query_params = params
      h = {}
      current_index_view_type = helpers.document_index_view_type(query_params)
      h[:view] = current_index_view_type unless current_index_view_type == helpers.default_document_index_view_type

      helpers.search_action_path(h)
    end
  end
end
