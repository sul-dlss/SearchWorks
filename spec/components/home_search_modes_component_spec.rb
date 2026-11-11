# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeSearchModesComponent, type: :component do
  let(:mode) { nil }
  let(:logged_in) { true }

  before do
    render_inline(described_class.new(mode:, logged_in:)) do |component|
      component.with_search { '<form id="search-form"></form>'.html_safe }
    end
  end

  it 'renders a tab for each mode' do
    expect(page).to have_css('[role="tablist"] [role="tab"]', count: 2)
    expect(page).to have_css('#home-mode-search-tab[aria-selected="true"][aria-controls="home-mode-search"]')
    expect(page).to have_css('#home-mode-chat-tab[aria-selected="false"][tabindex="-1"]')
  end

  it 'shows the search form and hides the chat panel by default' do
    expect(page).to have_css('#home-mode-search #search-form')
    expect(page).to have_css('#home-mode-chat[hidden] .chat-assistant', visible: :hidden)
  end

  context 'when the chat mode was requested' do
    let(:mode) { 'chat' }

    it 'renders the chat panel as the active pane' do
      expect(page).to have_css('.home-modes.chat-active')
      expect(page).to have_css('#home-mode-chat-tab[aria-selected="true"]')
      expect(page).to have_css('#home-mode-chat .chat-assistant')
      expect(page).to have_css('#home-mode-search[hidden]', visible: :hidden)
    end
  end

  context 'with an unknown mode' do
    let(:mode) { 'bogus' }

    it 'falls back to search' do
      expect(page).to have_css('#home-mode-search-tab[aria-selected="true"]')
    end
  end
end
