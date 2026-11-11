# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Chat assistant tool calls', :js do
  let(:events) do
    [
      ['tool_call', { id: 'call_1', name: 'catalog_search_tool', arguments: '{"query":"beloved morrison"}',
                      result: '1. Beloved / Toni Morrison' }],
      ['delta', { content: 'Green Library has a copy.' }],
      ['sources', { sources: [] }],
      ['done', {}]
    ].map { |event, data| "event: #{event}\ndata: #{data.to_json}\n\n" }
  end

  before do
    allow(Chat::Conversation).to receive(:new).and_return(instance_double(Chat::Conversation, each_event: events))
    login_as(User.create!(email: 'user@stanford.edu', password: 'totallysecurepassword'))
  end

  it 'lists each tool the assistant used, with its request and response collapsed' do
    visit '/?mode=chat'
    fill_in 'Ask the assistant a question', with: 'Where is Beloved?'
    click_on 'Send'

    expect(page).to have_text('Green Library has a copy.')
    within '.chat-message-assistant .chat-tool-call' do
      expect(page).to have_css('summary', text: 'catalog_search_tool')
      expect(page).to have_no_text('beloved morrison')

      find('summary').click

      expect(page).to have_css('pre', text: /"query": "beloved morrison"/)
      expect(page).to have_css('pre', text: '1. Beloved / Toni Morrison')
    end

    visit '/?mode=chat'

    expect(page).to have_css('.chat-tool-call summary', text: 'catalog_search_tool')
  end
end
