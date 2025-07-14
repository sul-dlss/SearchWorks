# frozen_string_literal: true

class CustomFacetSearchBuilder < FacetSearchBuilder
  self.default_processor_chain += [:force_facet_method_for_searching]

  # TODO: This search build seems like it also needs the customizations from our own SearchBuilder, but
  # this is not accounted for upstream?

  # We use facet.method=uif for normal faceting (presumably because it improves performance or
  # resource usage), but uif isn't compatible with facet.contains based searching.
  def force_facet_method_for_searching(solr_params)
    return if facet.blank?

    facet_config = blacklight_config.facet_fields[facet]
    solr_params[:"f.#{facet_config.field}.facet.method"] = 'fc'
  end
end
