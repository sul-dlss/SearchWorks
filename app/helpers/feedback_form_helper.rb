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
    end_tag = "</strong>"
    end_index = message_text.index(end_tag) + end_tag.length
    "#{message_text[0, end_index]} <br> #{message_text[end_index + 1, message_text.length]}"
  end
end
