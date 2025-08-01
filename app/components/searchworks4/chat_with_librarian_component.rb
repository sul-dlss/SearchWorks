# frozen_string_literal: true

module Searchworks4
  class ChatWithLibrarianComponent < ViewComponent::Base
    delegate :on_campus_or_su_affiliated_user?, to: :helpers

    # The default may change but this maintains the old design in other parts of the site
    def initialize(layout: 'inline', header_class: "h3")
      super
      @layout = layout
      @header_class = header_class
    end

    def chat_link(link_text)
      link_to("https://library.stanford.edu/contact-us", class: 'disabled start-chat me-2', data: { 'library-h3lp-target': 'link', action: 'library-h3lp#openChat' }) do
        safe_join([tag.span(class: 'bi bi-chat me-1', data: { 'library-h3lp-target': 'icon' }), link_text], ' ')
      end
    end

    def chat_attrs
      return {} unless on_campus_or_su_affiliated_user?

      { library_h3lp_jid_value: "ic@chat.libraryh3lp.com" }
    end
  end
end
