# frozen_string_literal: true

module ApplicationHelper
  def from_advanced_search?
    params[:search_field] == 'advanced' || params[:clause].present?
  end
end
