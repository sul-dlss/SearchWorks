# frozen_string_literal: true

module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  def resource_icon_value(values)
    values = Array(values).flatten.compact
    values.delete("Database") if values.length > 1
    values.delete("Book") if values.length > 1
    values.first
  end

  def render_resource_icon(values)
    value = resource_icon_value(values)
    return unless Constants::SUL_ICON_COMPONENTS.has_key?(value)

    render Constants::SUL_ICON_COMPONENTS[value].new
  end

  def render_articles_format_icon(value)
    return unless Constants::ARTICLES_ICON_COMPONENTS.has_key?(value)

    render Constants::ARTICLES_ICON_COMPONENTS[value].new
  end
end
