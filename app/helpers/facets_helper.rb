module FacetsHelper
  include Blacklight::FacetsHelperBehavior
  include BlacklightRangeLimit::ViewHelperOverride

  def collapse_home_page_facet?(facet)
    ['language', 'building_facet', 'format_main_ssim'].include? facet.field 
  end

  def render_single_facet(facet_name, options = {})
    facet = @response.aggregations.values.find do |facet|
      facet.name == facet_name
    end
    if facet
      render_facet_limit(facet_by_field_name(facet_name), options)
    end
  end

  # Overwrites blacklight_range_limit plugin method to remove parameters
  def remove_range_param(solr_field, my_params = params)
    my_params = my_params.clone #clone params so we only edit a copy for linking purposes
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

  def render_resource_icon(values)
    values = Array(values).flatten.compact
    values.delete("Database") if values.length > 1
    values.delete("Book") if values.length > 1
    value = values.first
    if Constants::SUL_ICONS.has_key?(value)
      content_tag(:span, "", class: "sul-icon sul-icon-#{Constants::SUL_ICONS[value]}")
    end
  end
end
