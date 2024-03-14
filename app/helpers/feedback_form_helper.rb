# frozen_string_literal: true

module FeedbackFormHelper
  def render_feedback_form(form_type)
    render 'shared/feedback_forms/form',
      type: form_type,
      target: form_type == 'connection' ? '#connection-form' : '#feedback-form'
  end

  def show_feedback_form?
    !controller.instance_of?(FeedbackFormsController)
  end

  def show_quick_report?
    if (params[:controller] == 'catalog' && params[:action] == 'show') or
      (refered_from_catalog_show? &&
        params[:controller] == 'feedback_forms' && params[:action] == 'new')
      true
    else
      false
    end
  end

  def refered_from_catalog_show?
    if request.referer.present?
      if /(\/catalog\/|\/view\/)/.match?(request.referer)
        true
      else
        false
      end
    end
  end
end
