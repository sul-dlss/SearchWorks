# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Article Record Toolbar', :js do
  let(:previous_document) { EdsDocument.new(id: 1, eds_title: 'My Prev Title') }
  let(:document) do
    EdsDocument.new(
      id: 2,
      eds_title: 'My Title',
      'exports' => {
        'Format' => 'RIS',
        'Data' => "TI  - CatZ N Bagelz\n"
      }
    )
  end
  let(:next_document) { EdsDocument.new(id: 3, eds_title: 'My Next Title') }

  before do
    stub_article_service(docs: [previous_document, document, next_document].compact)
    stub_article_service(type: :single, docs: [document])

    Capybara.current_session.reset!         # ensure a clean session
    visit articles_path q: 'my query'  # sets up search session
    click_link document[:eds_title]         # show the article record
  end

  it 'shows the Send button' do
    within '.record-toolbar' do
      expect(page).to have_css('form.bookmark-toggle')
      expect(page).to have_link('Email')
      expect(page).to have_button('Copy link')
      expect(page).to have_button('Print')
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
      within '.record-toolbar' do
        expect(page).to have_link('Next')
        expect(page).to have_no_link('Previous').and have_css('.previous', text: 'Previous')
      end
    end
  end

  context 'handles the last page (no next)' do
    let(:next_document) { nil }

    it 'shows only the Previous button' do
      within '.record-toolbar' do
        expect(page).to have_link('Previous')
        expect(page).to have_no_link('Next')
      end
    end
  end

  context 'handles a single page (no prev/next)' do
    let(:previous_document) { nil }
    let(:next_document) { nil }

    it 'does not show any Previous or Next buttons' do
      within '.record-toolbar' do
        expect(page).to have_no_link('Previous').and have_css('.previous', text: 'Previous')
        expect(page).to have_no_link('Next').and have_no_css('.next', text: 'Next')
      end
    end
  end
end
