module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  def collapse_home_page_facet?(facet)
    ['language', 'building_facet', 'format_main_ssim'].include? facet.field
  end

  def render_single_facet(facet_name, options = {})
    facet = @response.aggregations.values.find do |facet|
      facet.name == facet_name
    end

    render_facet_limit(facet, options) if facet
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
