# frozen_string_literal: true

module FeedbackFormHelper
  def show_quick_report?
    (params[:controller] == 'catalog' && params[:action] == 'show') or
      (refered_from_catalog_show? && params[:controller] == 'feedback_forms' && params[:action] == 'new')
  end

  def refered_from_catalog_show?
    if request.referer.present?
      /(\/catalog\/|\/view\/)/.match?(request.referer)
    end
  end
end
