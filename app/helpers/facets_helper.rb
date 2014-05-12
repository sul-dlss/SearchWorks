module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  def render_single_facet(facet_name, options={})
    facet = @response.facets.find do |facet|
      facet.name == facet_name
    end
    if facet
      render_facet_limit(facet_by_field_name(facet_name), options)
    end
  end
end
