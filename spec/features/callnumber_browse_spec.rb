# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Callnumber Browse', :js do
  describe 'embedded on the record page' do
    it 'renders' do
      visit solr_document_path('1')

      expect(page).to have_css('h2', text: 'Related items')
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

      expect(page).to have_css('[aria-label="Remove from saved records"]')

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
  end
end
