# frozen_string_literal: true

class ViewTypeDropdownComponent < Blacklight::Response::ViewTypeComponent
  renders_many :view_items, 'ViewTypeDropdownItemComponent'

  def with_view(...)
    with_view_item(...)
  end

  def active_icon
    active_view = @views[@selected] || @views.values.first

    return render(active_view.icon.new) if active_view.icon.is_a?(Class)
    return render(active_view.icon) if active_view.icon.is_a?(ViewComponent::Base)

    helpers.blacklight_icon(active_view.icon || @selected)
  end

  # TODO: Remove this in BL8.  See https://github.com/projectblacklight/blacklight/commit/7a7ce765e9f4bcbedc213a5ce792ea89906256af
  def render?
    helpers.document_index_views.many? && !@response.empty?
  end
end
