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

  include BlacklightRangeLimit::RangeLimitHelper
  def add_range_missing(solr_field, my_params = params)
    my_params = Marshal.load(Marshal.dump(my_params))
    my_params["range"] ||= {}

    # Commented out dummy range and other lines not needed for SearchWorks and are
    # causing errors when
    # my_params["range"][solr_field] ||= {}
    # my_params["range"][solr_field]["missing"] = "true"

    # Need to ensure there's a search_field to trick Blacklight
    # into displaying results, not placeholder page. Kind of hacky,
    # but works for now.
    # my_params["search_field"] ||= "dummy_range"

    my_params
  end
end
