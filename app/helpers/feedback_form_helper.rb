# frozen_string_literal: true

module FeedbackFormHelper
  def render_connection_form
    render 'shared/feedback_forms/form',
           type: 'connection',
           target: '#connection-form'
  end

  def show_connection_form?
    !controller.instance_of?(FeedbackFormsController)
  end

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
