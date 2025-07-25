# frozen_string_literal: true

module SearchResult
  module NoResult
    class ChatWithLibrarianComponent < ViewComponent::Base
      delegate :on_campus_or_su_affiliated_user?, to: :helpers

      def chat_attrs
        return {} unless on_campus_or_su_affiliated_user?

        { library_h3lp_jid_value: "ic@chat.libraryh3lp.com", controller: 'library-h3lp', action: 'click->library-h3lp#openChat' }
      end
    end
  end
end
