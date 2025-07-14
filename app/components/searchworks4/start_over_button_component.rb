# frozen_string_literal: true

# Overrides the default Blacklight StartOverButtonComponent in order to
# update btn class to btn-outline-primary
module Searchworks4
  class StartOverButtonComponent < Blacklight::StartOverButtonComponent
    def call
      link_to t('blacklight.search.start_over'), start_over_path, class: 'btn btn-outline-primary btn-reset'
    end

    def start_over_path
      case access_point
      when :government_documents
        search_catalog_path(q: search_state.query_param, f: { genre_ssim: ['Government document'] })
      when :dissertation_theses
        search_catalog_path(q: search_state.query_param, f: { genre_ssim: ['Thesis/dissertation'] })
      when :digital_collections
        search_catalog_path(q: search_state.query_param, f: { collection_type: ['Digital Collection'] })
      else
        search_catalog_path(q: search_state.query_param)
      end
    end

    delegate :search_state, to: :helpers
    delegate :access_point, to: :page_location

    def page_location
      @page_location ||= PageLocation.new(helpers.search_state)
    end
  end
end
