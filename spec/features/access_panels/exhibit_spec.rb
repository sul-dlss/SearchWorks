# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Exhibit Access Panel', :js do
  let(:content) { [] }
  before do
    expect(Settings.EXHIBITS_ACCESS_PANEL).to receive(:exhibits_host).and_return(
      "http://127.0.0.1:#{Capybara.current_session.server.port}"
    )

    MockExhibitsFinderEndpoint.configure do |endpoint|
      endpoint.content = content.to_json
    end
  end

  context 'when there are no exhibits' do
    it 'does not display the Context heading' do
      visit '/view/mf774fs2413'
      expect(page).to have_no_css('[data-behavior="exhibits-panel"]', visible: true)

      expect(page).to have_css('h2', text: 'Context', visible: false)
    end
  end

  context 'when there is one exhibit' do
    let(:content) do
      [{ slug: 'exhibit1', title: 'Exhibit Title' }]
    end

    it 'displays the Context heading' do
      visit '/view/mf774fs2413'
      expect(page).to have_css('[data-behavior="exhibits-panel"]', visible: true)

      expect(page).to have_css('h2', text: 'Context', visible: true)
    end

    it 'has a specific panel title' do
      visit '/view/mf774fs2413'
      expect(page).to have_css('[data-behavior="exhibits-panel"]', visible: true)

      within '[data-behavior="exhibits-panel"]' do
        expect(page).to have_css('h3', text: 'Item is featured in an exhibit')
      end
    end

    it 'renders the panel with a media object for each exhibit' do
      visit '/view/mf774fs2413'
      expect(page).to have_css('[data-behavior="exhibits-panel"]', visible: true)

      within '[data-behavior="exhibits-panel"]' do
        expect(page).to have_css('.media', count: 1)
      end
    end

    it 'links the title' do
      visit '/view/mf774fs2413'
      expect(page).to have_css('[data-behavior="exhibits-panel"]', visible: true)

      within '[data-behavior="exhibits-panel"] .media-heading' do
        expect(page).to have_link('Exhibit Title')
      end
    end
  end

  context 'when the exhibit has a thumbnail' do
    let(:content) do
      [{ slug: 'exhibit1', title: 'Exhibit Title', thumbnail_url: 'http://example.com/thumb.jpg' }]
    end

    it 'is displayed and linked' do
      visit '/view/mf774fs2413'
      expect(page).to have_css('[data-behavior="exhibits-panel"]', visible: true)

      within '[data-behavior="exhibits-panel"]' do
        expect(page).to have_css('a img[src="http://example.com/thumb.jpg"]', visible: false)
      end
    end
  end

  context 'when the exhibit has a subtitle' do
    let(:content) do
      [{ slug: 'exhibit1', title: 'Exhibit Titlte', subtitle: 'The subtitle' }]
    end

    it 'is displayed' do
      visit '/view/mf774fs2413'
      expect(page).to have_css('[data-behavior="exhibits-panel"]', visible: true)

      within '[data-behavior="exhibits-panel"]' do
        expect(page).to have_css('.media-heading', text: /The subtitle$/)
      end
    end
  end

  context 'when there are more than 5 exhibits' do
    let(:content) do
      7.times.map do |index|
        { slug: "exhibit-#{index}", title: "Exhibit #{index} Title" }
      end
    end

    it 'has a specific panel title' do
      visit '/view/mf774fs2413'
      expect(page).to have_css('[data-behavior="exhibits-panel"]', visible: true)

      within '[data-behavior="exhibits-panel"]' do
        expect(page).to have_css('h3', text: 'Item is featured in exhibits')
      end
    end

    it 'only displays the first 5 exhibits and has a link to toggle any additional' do
      skip('Passes locally, fails intermittently on Travis.') if ENV['CI']
      visit '/view/mf774fs2413'
      expect(page).to have_css('[data-behavior="exhibits-panel"]', visible: true)

      within '[data-behavior="exhibits-panel"]' do
        expect(page).to have_css('.media', count: 5, visible: true)
        expect(page).to have_button('show all 7 exhibits')
        click_button('show all 7 exhibits')
        expect(page).to have_css('.media', count: 7, visible: true)
        expect(page).to have_no_button('show all 7 exhibits')
      end
    end
  end

  context 'when the document is an item' do
    let(:content) do
      [{ slug: 'exhibit1', title: 'Exhibit Title' }]
    end

    it 'links to the document within the exhibit' do
      visit '/view/mf774fs2413'
      expect(page).to have_css('[data-behavior="exhibits-panel"]', visible: true)

      within '[data-behavior="exhibits-panel"]' do
        expect(page).to have_link('Exhibit Title', href: %r{/exhibit1/catalog/mf774fs2413$})
      end
    end
  end

  context 'when the document is a collection' do
    let(:content) do
      [{ slug: 'exhibit1', title: 'Exhibit Title' }]
    end

    it 'has a specific panel title' do
      visit '/view/34'
      expect(page).to have_css('[data-behavior="exhibits-panel"]', visible: true)

      within '[data-behavior="exhibits-panel"]' do
        expect(page).to have_css('h3', text: 'Exhibit')
      end
    end

    it 'links to the exhibit landing page' do
      visit '/view/34'

      expect(page).to have_css('[data-behavior="exhibits-panel"]', visible: true)

      within '[data-behavior="exhibits-panel"]' do
        expect(page).to have_link('Exhibit Title', href: %r{/exhibit1$})
      end
    end
  end
end
