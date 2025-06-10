# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Callnumber Browse', :js do
  describe 'embedded on the record page' do
    it 'renders' do
      visit solr_document_path('1')

      expect(page).to have_css('h2', text: 'Browse related items')
    end

    it 'has select boxes that work' do
      visit solr_document_path('1')

      expect(page).to have_css('.embedded-items')

      within '.current-document' do
        first('.toggle-bookmark-label').click
      end

      expect(page).to have_css '[data-behavior="recent-selections"]', text: 'Selections (1)'
      expect(page).to have_checked_field visible: :hidden
      expect(page).to have_css('.bookmark-checked')
    end
  end

  describe 'full browse view' do
    it 'is successful and checkboxes stay checked after refresh' do
      visit solr_document_path('1')

      within '.record-browse-nearby' do
        click_link 'View full page'
      end

      expect(page).to have_css('h1', text: 'Browse related items')

      bookmarks = all('.toggle-bookmark-label')
      bookmarks.first.click
      bookmarks.last.click

      expect(page).to have_css('.bookmark-checked')

      page.driver.browser.navigate.refresh

      expect(page).to have_checked_field visible: :hidden

      expect(page).to have_css('[data-behavior="recent-selections"]', text: 'Selections (2)')
    end

    it 'allows the user to pick the view type' do
      visit solr_document_path('1')

      within '.record-browse-nearby' do
        click_link 'View full page'
      end

      expect(page).to have_text('Starting at call number: G70.212')

      within '#view-type-dropdown' do
        click_button 'View'
        click_link 'brief'
      end

      expect(page).to have_text('Starting at call number: G70.212')
    end
  end
end
