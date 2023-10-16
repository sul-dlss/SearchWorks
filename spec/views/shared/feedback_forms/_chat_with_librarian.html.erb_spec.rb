require 'rails_helper'

RSpec.describe 'shared/feedback_forms/_chat_with_librarian' do
  before do
    render
  end

  it 'should have correct data attributes' do
    expect(rendered).to have_css('[data-jid="ic@chat.libraryh3lp.com"]')
    expect(rendered).to have_css('[data-library-h3lp]')
  end
end
