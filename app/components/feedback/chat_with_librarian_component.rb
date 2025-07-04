# frozen_string_literal: true

module Feedback
  class ChatWithLibrarianComponent < ViewComponent::Base
    delegate :on_campus_or_su_affiliated_user?, to: :helpers

    # The default may change but this maintains the old design in other parts of the site
    def initialize(header_class: "h3")
      super
      @header_class = header_class
    end

    def chat_attrs
      return {} unless on_campus_or_su_affiliated_user?

      { library_h3lp_jid_value: "ic@chat.libraryh3lp.com", controller: 'library-h3lp', action: 'click->library-h3lp#openChat' }
    end
  end
end
