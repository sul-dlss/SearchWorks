# frozen_string_literal: true

class ArticlesRangeLimitComponent < BlacklightRangeLimit::RangeFacetComponent
  def date_range
    Eds::DateRangeParser.new(@facet_field.response, params, @facet_field.key)
  end
end
