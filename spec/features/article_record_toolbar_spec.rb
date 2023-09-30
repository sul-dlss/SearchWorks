require 'spec_helper'

RSpec.describe 'Article Record Toolbar', js: true do
  let(:previous_document) { SolrDocument.new(id: 1, eds_title: 'My Prev Title') }
  let(:document) do
    SolrDocument.new(
      id: 2,
      eds_title: 'My Title',
      eds_citation_exports: [{ 'id' => 'RIS', 'data' => 'TI  - CatZ N Bagelz' }]
    )
  end
  let(:next_document) { SolrDocument.new(id: 3, eds_title: 'My Next Title') }

  before do
    stub_article_service(docs: [previous_document, document, next_document].compact)
    stub_article_service(type: :single, docs: [document])

    Capybara.current_session.reset!         # ensure a clean session
    visit articles_path q: 'my query'  # sets up search session
    click_on document[:eds_title]           # show the article record
  end

  it 'shows the Send button' do
    within '.record-toolbar' do
      expect(page).to have_css('.btn-sul-toolbar', text: 'Send to')
      expect(page).to have_link('text', visible: false)
      expect(page).to have_link('email', visible: false)
      expect(page).to have_link('RefWorks', visible: false)
      expect(page).to have_link('RIS download', visible: false)
      expect(page).to have_link('printer', visible: false)
    end
  end
  it 'shows both prev and next buttons' do
    within '.record-toolbar' do
      expect(page).to have_css('.previous', text: 'Previous')
      expect(page).to have_css('.next', text: 'Next')
    end
  end

  context 'handles the first page (no prev)' do
    let(:previous_document) { nil }

    it 'shows only the Next button' do
      skip 'TODO: disabled temporarily'
      within '.record-toolbar' do
        expect(page).not_to have_css('.previous', text: 'Previous')
        expect(page).to have_css('.next', text: 'Next')
      end
    end
  end

  context 'handles the last page (no next)' do
    let(:next_document) { nil }

    it 'shows only the Previous button' do
      skip 'TODO: disabled temporarily'
      within '.record-toolbar' do
        expect(page).to have_css('.previous', text: 'Previous')
        expect(page).not_to have_css('.next', text: 'Next')
      end
    end
  end

  context 'handles a single page (no prev/next)' do
    let(:previous_document) { nil }
    let(:next_document) { nil }

    it 'does not show any Previous or Next buttons' do
      skip 'TODO: disabled temporarily'
      within '.record-toolbar' do
        expect(page).not_to have_css('.previous', text: 'Previous')
        expect(page).not_to have_css('.next', text: 'Next')
      end
    end
  end
end
