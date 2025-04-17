# frozen_string_literal: true

module SearchResult
  module NoResult
    class ChatWithLibrarianComponent < ViewComponent::Base
      delegate :allowed_to?, to: :helpers

      def chat_attrs
        return {} unless allowed_to?(:create?, with: OnlineChatPolicy)

        { library_h3lp: 'true', jid: "ic@chat.libraryh3lp.com" }
      end
    end
  end
end
