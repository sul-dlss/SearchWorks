# frozen_string_literal: true

# The AI chat assistant panel on the home page (chat_assistant_controller.js). Anonymous users
# see what the assistant does and a login button that returns them to the chat.
class ChatPanelComponent < ViewComponent::Base
  EXAMPLE_QUESTIONS = [
    'Where can I find a copy of Beloved by Toni Morrison?',
    'Recent peer-reviewed articles on coral reef bleaching',
    'Maps of San Francisco from before 1906'
  ].freeze

  def initialize(logged_in:)
    super()
    @logged_in = logged_in
  end

  attr_reader :logged_in

  def login_url
    helpers.new_user_session_path(referrer: '/?mode=chat')
  end
end
