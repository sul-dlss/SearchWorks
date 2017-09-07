module FeedbackFormHelper

  def render_feedback_form(form_type)
    case form_type
    when 'connection'
      render 'shared/feedback_forms/connection_form'
    else
      render 'shared/feedback_forms/form'
    end
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
      if request.referer =~ /(\/catalog\/|\/view\/)/
        true
      else
        false
      end
    end
  end
end
