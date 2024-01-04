# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_chat_librarian_sidebar' do
  context 'on campus or logged in' do
    before do
      allow(view).to receive(:on_campus_or_su_affiliated_user?).and_return true
      render
    end

    it 'renders a link to chat' do
      expect(rendered).to have_css 'a', text: 'Chat with a librarian'
    end

    it 'has correct data attributes' do
      expect(rendered).to have_css('[data-jid="ic@chat.libraryh3lp.com"]')
      expect(rendered).to have_css('[data-library-h3lp]')
      expect(rendered).to have_css('[data-hours-route=\'/hours/IC-CHAT\']')
      expect(rendered).to have_css '.location-hours-today'
    end
  end

  context 'off campus or not logged in' do
    before do
      allow(view).to receive(:on_campus_or_su_affiliated_user?).and_return(false)
      render
    end

    it 'renders alternative view' do
      expect(rendered).to have_css 'h3', text: 'Chat with a librarian'
      expect(rendered).to have_no_css 'a', text: 'Chat with a librarian'
      expect(rendered).to have_css 'a', text: 'Login to access chat assistance.'
    end
  end
end
