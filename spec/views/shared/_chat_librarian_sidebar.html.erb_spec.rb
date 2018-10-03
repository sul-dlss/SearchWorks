require 'spec_helper'

describe 'shared/_chat_librarian_sidebar.html.erb' do
  before do
    expect(view).to receive(:on_campus_or_su_affiliated_user?).and_return true
    render
  end
  it 'should have correct data attributes' do
    expect(rendered).to have_css('[data-jid="ic@chat.libraryh3lp.com"]')
    expect(rendered).to have_css('[data-library-h3lp]')
    expect(rendered).to have_css('[data-hours-route=\'/hours/IC\']')
    expect(rendered).to have_css '.location-hours-today'
  end
  context 'off campus or not logged in' do
    before do
      expect(view).to receive(:on_campus_or_su_affiliated_user?).and_return false
      render
    end
    it 'renders alternative view' do
      expect(rendered).to have_css 'a', text: 'Chat with a librarian'
      expect(rendered).to have_css 'a', text: 'Login to access chat assistance.'
    end
  end
end
