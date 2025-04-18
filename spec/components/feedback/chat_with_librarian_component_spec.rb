# frozen_string_literal: true

require "rails_helper"

RSpec.describe Feedback::ChatWithLibrarianComponent, type: :component do
  before do
    allow(vc_test_controller).to receive(:on_campus_or_su_affiliated_user?).and_return logged_in
    render_inline(described_class.new)
  end

  context 'on campus or logged in' do
    let(:logged_in) { true }

    it 'renders the component' do
      expect(page).to have_css '.h3', text: 'Chat with a librarian'
      expect(page).to have_link 'Start chat'

      expect(page).to have_css '[data-jid="ic@chat.libraryh3lp.com"]'
      expect(page).to have_css '[data-library-h3lp]'
      expect(page).to have_css '[data-controller="chat-hours"]'
      expect(page).to have_css '[data-chat-hours-url-value]'
    end
  end

  context 'off campus or not logged in' do
    let(:logged_in) { false }

    it 'renders alternative view' do
      expect(page).to have_css '.h3', text: 'Chat with a librarian'

      expect(page).to have_no_css '[data-jid="ic@chat.libraryh3lp.com"]'
      expect(page).to have_no_css '[data-library-h3lp]'
      expect(page).to have_css '[data-controller="chat-hours"]'
      expect(page).to have_css '[data-chat-hours-url-value]'
    end
  end
end
