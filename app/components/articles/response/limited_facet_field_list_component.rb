# frozen_string_literal: true

module Articles
  module Response
    # Because the EDS api doesn't support facet limit, we fake it.
    class LimitedFacetFieldListComponent < Blacklight::FacetFieldListComponent
    end
  end
end
