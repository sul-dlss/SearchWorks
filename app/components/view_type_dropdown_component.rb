# frozen_string_literal: true

class ViewTypeDropdownComponent < Blacklight::Response::ViewTypeComponent
  renders_many :view_items, 'ViewTypeDropdownItemComponent'

  def with_view(...)
    with_view_item(...)
  end

  def active_icon
    helpers.render_view_type_group_icon(@selected)
  end
end
