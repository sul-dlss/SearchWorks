# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatPanelComponent, type: :component do
  before { render_inline(described_class.new(logged_in:)) }

  context 'when logged in' do
    let(:logged_in) { true }

    it 'renders the chat form and clickable example questions' do
      expect(page).to have_css('[data-controller="chat-assistant"][data-chat-assistant-url-value="/chat"]')
      expect(page).to have_field('Ask the assistant a question')
      expect(page).to have_button('Where can I find a copy of Beloved by Toni Morrison?')
      expect(page).to have_css('.chat-assistant-login[hidden]', visible: :hidden)
    end
  end

  context 'when not logged in' do
    let(:logged_in) { false }

    it 'explains the assistant and offers a login that returns to the chat' do
      expect(page).to have_no_field('Ask the assistant a question')
      expect(page).to have_text('Where can I find a copy of Beloved by Toni Morrison?')
      expect(page).to have_no_button('Where can I find a copy of Beloved by Toni Morrison?')
      expect(page).to have_link('Log in to chat', href: '/sso/login?referrer=%2F%3Fmode%3Dchat')
    end
  end
end
