module FeedbackFormHelper

  def show_feedback_form?
    !controller.instance_of?(FeedbackFormsController)
  end

  def show_quick_report?
    refer = Rails.application.routes.recognize_path(request.referer)
    if (params[:controller] == 'catalog' && params[:action] == 'show') or
      (refer[:controller] == 'catalog' && refer[:action] == 'show' &&
        params[:controller] == 'feedback_forms' && params[:action] == 'new')
      true
    else
      false
    end
  end
end
