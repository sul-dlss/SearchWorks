module FeedbackFormHelper

  def show_feedback_form?
    !controller.instance_of?(FeedbackFormsController)
  end

  def show_quick_report?
    unless request.referer.nil?
      refer = Rails.application.routes.recognize_path(
        request.referer.to_s.gsub(request.base_url.to_s, '')
      )
      if (params[:controller] == 'catalog' && params[:action] == 'show') or
        (refer[:controller] == 'catalog' && refer[:action] == 'show' &&
          params[:controller] == 'feedback_forms' && params[:action] == 'new')
        true
      else
        false
      end
    end
  end
end
