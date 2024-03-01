# frozen_string_literal: true

class ViewTypeDropdownComponent < Blacklight::Response::ViewTypeComponent
  renders_many :view_items, 'ViewTypeDropdownItemComponent'

  def with_view(...)
    with_view_item(...)
  end

  def active_icon
    helpers.render_view_type_group_icon(@selected)
  end

  # TODO: Remove this in BL8.  See https://github.com/projectblacklight/blacklight/commit/7a7ce765e9f4bcbedc213a5ce792ea89906256af
  def render?
    helpers.document_index_views.many? && !@response.empty?
  end
end
