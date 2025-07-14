# frozen_string_literal: true

module Searchworks4
  class LibraryFacetComponent < Blacklight::Facets::ListComponent
    def facet_item_presenters
      super.sort_by(&:label).reject do |presenter|
        presenter.label == 'SUL' || presenter.label.starts_with?('SAL')
      end
    end

    def render?
      super && facet_item_presenters.any?
    end
  end
end
