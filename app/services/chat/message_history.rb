# frozen_string_literal: true

module Chat
  # Validates and bounds the user-visible messages the browser supplies to a conversation.
  # Transcripts live in the browser, so every turn resubmits the history it wants the model to see.
  class MessageHistory
    class InvalidMessages < StandardError; end

    def self.normalize(value)
      messages = Array(value).map do |message|
        raise InvalidMessages, 'Each message must have a valid role and content.' unless message.respond_to?(:to_h)

        message = message.to_h.stringify_keys
        role = message['role']
        content = message['content']
        raise InvalidMessages, 'Each message must have a valid role and content.' unless %w[user assistant].include?(role)
        raise InvalidMessages, 'Each message must have a valid role and content.' unless content.is_a?(String) && content.present?

        { 'role' => role, 'content' => content.first(config.max_message_characters) }
      end
      raise InvalidMessages, 'Enter a message to start chatting.' if messages.empty?
      raise InvalidMessages, 'The last message must be from the user.' unless messages.last['role'] == 'user'

      trim_to_character_limit(messages.last(config.max_history_messages))
    end

    def self.config
      Rails.configuration.x.chat
    end

    # Keeps the newest messages that fit, always including the latest question.
    def self.trim_to_character_limit(messages)
      kept = []
      characters = 0
      messages.reverse_each do |message|
        break if characters + message['content'].length > config.max_history_characters && kept.any?

        kept << message
        characters += message['content'].length
      end
      kept.reverse
    end
    private_class_method :config, :trim_to_character_limit

    def initialize(messages)
      @messages = self.class.normalize(messages)
    end

    def self.system_prompt
      [SearchworksMcp::INSTRUCTIONS, Rails.configuration.x.chat.system_prompt].join("\n\n")
    end

    def with_system_prompt
      [{ 'role' => 'system', 'content' => self.class.system_prompt }] + @messages
    end

    def last_user_content
      @messages.last.fetch('content')
    end
  end
end
