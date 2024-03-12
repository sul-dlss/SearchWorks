# frozen_string_literal: true

module FacetsHelper
  include Blacklight::FacetsHelperBehavior

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
