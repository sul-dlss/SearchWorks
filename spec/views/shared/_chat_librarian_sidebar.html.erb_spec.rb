require 'spec_helper'

describe 'shared/_chat_librarian_sidebar.html.erb' do
  before do
    render
  end
  it 'should have correct data attributes' do
    expect(rendered).to have_css('[data-jid="ic@chat.libraryh3lp.com"]')
    expect(rendered).to have_css('[data-library-h3lp]')
    expect(rendered).to have_css('[data-hours-route=\'/hours/IC\']')
    expect(rendered).to have_css '.location-hours-today'
  end
end
