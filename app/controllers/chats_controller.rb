# frozen_string_literal: true

# Streams answers from the AI chat assistant on the home page. Each turn runs the SearchWorks MCP
# tools in-process; the transcript lives in the browser and is resubmitted with every turn.
class ChatsController < ApplicationController
  before_action :ensure_enabled
  before_action :ensure_logged_in

  # POST /chat
  def create
    conversation = Chat::Conversation.new(
      messages: submitted_messages,
      controller: self,
      eds_guest: !on_campus_or_su_affiliated_user?
    )

    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache, no-store'
    response.headers['X-Accel-Buffering'] = 'no'
    # Rack::ETag buffers a response that has no validator, which would hold the stream back.
    response.headers['Last-Modified'] = Time.current.httpdate
    self.response_body = conversation.each_event
  rescue ActionController::ParameterMissing, Chat::Conversation::InvalidMessages => e
    render json: { error: e.message }, status: :unprocessable_content
  end

  private

  def ensure_enabled
    raise ActionController::RoutingError, 'Not Found' unless Settings.chat.enabled
  end

  def ensure_logged_in
    return if current_user

    render json: { error: 'Log in to use the SearchWorks assistant.', login_url: new_user_session_path(referrer: '/?mode=chat') },
           status: :unauthorized
  end

  def submitted_messages
    messages = params.require(:messages)
    raise Chat::Conversation::InvalidMessages, 'Messages must be an array.' unless messages.is_a?(Array)

    messages.map { |message| message.respond_to?(:to_unsafe_h) ? message.to_unsafe_h : message }
  end
end
