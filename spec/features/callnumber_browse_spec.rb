# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Callnumber Browse', :js do
  describe 'embedded on the record page' do
    it 'renders buttons to switch call numbers and marks the current item' do
      visit solr_document_path('14205849')

      expect(page).to have_css('h2', text: 'Related items')
      expect(page).to have_button 'PQ3949.2 .C65 Z74 2021'
      expect(page).to have_button '840.5 .Y18'
      within '#callnumber-0' do
        expect(page).to have_text 'PQ3949.2 .C65 Z74 2021'
        expect(page).to have_css '.current-document'
      end

      click_button '840.5 .Y18'
      within '#callnumber-1' do
        expect(page).to have_text '840.5 .Y18'
        expect(page).to have_css '.current-document'
      end
    end

    it 'has select boxes that work' do
      visit solr_document_path('1')
      expect(page).to have_css('.embedded-items')

      within '.current-document' do
        find('.toggle-bookmark').click
      end

      expect(page).to have_link 'Saved 1'
    end
  end

  describe 'full browse view' do
    it 'is successful and checkboxes stay checked after refresh' do
      visit solr_document_path('1')

      within '.record-browse-nearby' do
        click_link 'Full page'
      end

      expect(page).to have_css('h1', text: 'Browse related items')
      expect(page).to have_css('.gallery-document.current-document')

      within '.document-position-11' do
        find('.toggle-bookmark').click
      end
      within '.document-position-12' do
        find('.toggle-bookmark').click
      end

      expect(page).to have_css('[data-tooltip="Remove from saved records"]')

      page.driver.browser.navigate.refresh

      expect(page).to have_text 'Saved'
      expect(page).to have_css('.bookmark-counter', text: '2')
    end

    it 'allows the user to pick the view type' do
      visit solr_document_path('1')

      within '.record-browse-nearby' do
        click_link 'Full page'
      end

      expect(page).to have_text('Starting at call number: G70.212')
    end

    it 'allows the user to start a new search without carrying over the browse state' do
      stub_article_service(docs: [])
      visit browse_index_path(call_number: 'A', start: '1')
      expect(page).to have_text('Starting at call number: A')

      fill_in 'q', with: 'biography'
      click_button 'Search'

      expect(page).to have_css('.constraint.query', text: 'biography')
      expect(page).to have_no_css('.constraint.filter')
    end
  end

  scenario 'Results are rendered properly', :js do
    visit browse_index_path(call_number: 'A', start: '1', after: '0', view: 'gallery')

    within '.gallery-document[data-document-id="1391872"]' do
      expect(page).to have_css('div.callnumber-bar', text: 'KKX3800 .H49 1973')
      expect(page).to have_css(
        ".fake-cover", text: 'Book cover not available', visible: :hidden
      )
      expect(page).to have_css '.gallery-document h3.index_title', text: 'Studies in old Ottoman criminal law'

      expect(page).to have_css '.toggle-bookmark'
      expect(page).to have_button 'preview'
      click_button 'preview'
    end
    within '.preview-container' do
      expect(page).to have_css('h3', text: 'Studies in old Ottoman criminal law')
    end
  end
end
