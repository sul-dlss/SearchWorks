# frozen_string_literal: true

module Chat
  module Evaluation
    # Asks the chat assistant a question in-process, with the real model and the real catalog, EDS,
    # and FOLIO services of the environment it runs in. Running in-process means the evaluation
    # needs no way around ChatsController's login requirement.
    class LocalChatClient
      # The server sends this notice, then a done event, when the model hits its output token limit.
      LENGTH_LIMIT_NOTICE = 'reached its length limit'

      Result = Data.define(:answer, :sources, :availability, :tool_calls, :notices) do
        def truncated?
          notices.any? { |notice| notice.to_s.include?(LENGTH_LIMIT_NOTICE) }
        end
      end

      class RequestError < StandardError; end

      # @param eds_guest [Boolean] whether article tools query EDS as a guest
      def initialize(eds_guest: false, conversation_class: Chat::Conversation)
        @eds_guest = eds_guest
        @conversation_class = conversation_class
      end

      def ask(question, history: [])
        messages = Array(history).map { |message| message.to_h.stringify_keys }
        messages << { 'role' => 'user', 'content' => question }
        answer = +''
        result = { sources: [], availability: [], tool_calls: [], notices: [] }

        @conversation_class.new(messages:, eds_guest: @eds_guest).run do |event, data|
          case event
          when 'delta' then answer << data[:content]
          when 'reset' then answer = +''
          when 'sources' then result[:sources] = data[:sources].map(&:stringify_keys)
          when 'availability' then result[:availability] << data
          when 'tool_call' then result[:tool_calls] << data.slice(:name, :arguments)
          when 'notice' then result[:notices] << data[:message]
          when 'error' then raise RequestError, data[:message]
          end
        end

        Result.new(answer:, **result)
      end
    end
  end
end
