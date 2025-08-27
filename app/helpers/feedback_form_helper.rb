# frozen_string_literal: true

module FeedbackFormHelper
  def render_connection_form
    render 'shared/feedback_forms/form',
           type: 'connection',
           target: '#connection-form'
  end
end
