# frozen_string_literal: true

module ApplicationHelper
  def from_advanced_search?
    params[:search_field] == 'advanced' || params[:clause].present?
  end

  def modal_back_link
    return unless params[:backlink_href]

    link_to(
      params[:backlink_href],
      data: { blacklight_modal: 'trigger' }
    ) do
      safe_join([
        tag.i(class: 'bi bi-forward-fill rotate-180 me-1', aria: { hidden: true }),
        "Back to #{params[:backlink_label]}"
      ])
    end
  end
end
