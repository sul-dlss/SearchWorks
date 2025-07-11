# frozen_string_literal: true

module ApplicationHelper
  def active_class_for_current_page(page)
    if current_page?(page)
      "active"
    end
  end

  def from_advanced_search?
    params[:search_field] == 'advanced' || params[:clause].present?
  end
end
