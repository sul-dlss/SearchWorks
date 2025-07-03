# frozen_string_literal: true

module FeedbackFormHelper
  def render_connection_form
    render 'shared/feedback_forms/form',
           type: 'connection',
           target: '#connection-form'
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

  def breakout_message(message_text)
    beginTag = "<strong>"
    endTag = "</strong>"
    endIndex = message_text.index(endTag) + endTag.length
    return "#{message_text[0, endIndex]} <br> #{message_text[endIndex + 1, message_text.length]}"
  end
end
