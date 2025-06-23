# frozen_string_literal: true

module Facets
  class FiltersComponent < Blacklight::Facets::FiltersComponent
    # TODO: Remove instance variables and template after https://github.com/projectblacklight/blacklight/pull/3655
    def initialize(presenter:, classes: 'facet-filters card card-body p-3 mb-3 border-0',
                   suggestions_component: SuggestComponent,
                   index_navigation_component: Blacklight::Facets::IndexNavigationComponent)
      @suggestions_component = suggestions_component
      @index_navigation_component = index_navigation_component
      super(presenter:, classes:)
    end

    attr_reader :suggestions_component, :index_navigation_component

    def suggestions
      render suggestions_component.new(presenter: presenter)
    end

    def index_navigation
      render index_navigation_component.new(presenter: presenter)
    end
  end
end
