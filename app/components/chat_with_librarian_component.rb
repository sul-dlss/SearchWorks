# frozen_string_literal: true

class ChatWithLibrarianComponent < ViewComponent::Base
  delegate :on_campus_or_su_affiliated_user?, to: :helpers

  def chat_attrs
    return {} unless on_campus_or_su_affiliated_user?

    { library_h3lp: 'true', jid: "ic@chat.libraryh3lp.com" }
  end
end
