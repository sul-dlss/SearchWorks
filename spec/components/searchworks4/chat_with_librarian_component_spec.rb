# frozen_string_literal: true

require "rails_helper"

RSpec.describe Searchworks4::ChatWithLibrarianComponent, type: :component do
  before do
    allow(vc_test_controller).to receive(:allowed_to?).and_return logged_in
    render_inline(described_class.new)
  end

  context 'when on campus or logged in' do
    let(:logged_in) { true }

    it 'renders the component' do
      expect(page).to have_css '.h3', text: 'Chat with a librarian'
      expect(page).to have_link 'Start chat'

      expect(page).to have_css '[data-library-h3lp-jid-value="ic@chat.libraryh3lp.com"]'
      expect(page).to have_css '[data-library-h3lp-hours-url-value]'
    end
  end

  context 'when off campus or not logged in' do
    let(:logged_in) { false }

    it 'renders alternative view' do
      expect(page).to have_css '.h3', text: 'Chat with a librarian'

      expect(page).to have_no_css '[data-library-h3lp-jid-value="ic@chat.libraryh3lp.com"]'
      expect(page).to have_css '[data-library-h3lp-hours-url-value]'
    end
  end
end
