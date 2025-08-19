# frozen_string_literal: true

module Searchworks4
  class ConstraintComponent < Blacklight::ConstraintComponent
    # The prefix method is available on our customized facet item presenters
    # but not for all facet item presenter classes
    # This method will return nil in case the class has not implemented the prefix method
    # This method returns the text that will show up for the selected advanced search clauses,
    # inclusive facets, and negative facets.
    def prefix
      @facet_item_presenter.facet_item_presenter.respond_to?(:prefix) ? @facet_item_presenter.facet_item_presenter.prefix : nil
    end
  end
end
