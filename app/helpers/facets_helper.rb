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

  # Don't let rubocop change values.include? to .values?
  # rubocop:disable Performance/InefficientHashSearch
  def add_filter_unless_present(state, filter_key, value)
    state = state.filter(filter_key).add(value) unless state.filter(filter_key).values.include?(value)
    state
  end

  def remove_filter_if_present(state, filter_key, value)
    state = state.filter(filter_key).remove(value) if state.filter(filter_key).values.include?(value)
    state
  end
  # rubocop:enable Performance/InefficientHashSearch
end
