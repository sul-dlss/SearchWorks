# frozen_string_literal: true

module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  def render_resource_icon(values)
    values = Array(values).flatten.compact
    values.delete("Database") if values.length > 1
    values.delete("Book") if values.length > 1
    value = values.first
    return unless Constants::SUL_ICON_COMPONENTS.has_key?(value)

    render Constants::SUL_ICON_COMPONENTS[value].new
  end
end
