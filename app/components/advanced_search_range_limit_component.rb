# frozen_string_literal: true

class AdvancedSearchRangeLimitComponent < ViewComponent::Base
  def initialize(facet_field:, **kwargs)
    @facet_field = facet_field
  end
end
