module FacetsHelper
  include Blacklight::FacetsHelperBehavior
  include BlacklightRangeLimit::ViewHelperOverride


  def render_single_facet(facet_name, options={})
    facet = @response.facets.find do |facet|
      facet.name == facet_name
    end
    if facet
      render_facet_limit(facet_by_field_name(facet_name), options)
    end
  end

  # Overwrites blacklight_range_limit plugin method to remove parameters
  def remove_range_param(solr_field, my_params = params)
    if my_params["range"]
      my_params.delete("range")
      if my_params["search_field"].present? &&
        ["dummy_range", "search"].include?(my_params["search_field"])
        my_params.delete("search_field")
      end
      my_params.delete("commit")
    end
    return my_params
  end
end
