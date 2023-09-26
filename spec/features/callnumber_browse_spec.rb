require 'spec_helper'

RSpec.describe 'Callnumber Browse', js: true do
  describe 'embedded on the record page' do
    it 'renders' do
      visit solr_document_path('1')

      expect(page).to have_css('h2', text: 'Browse related items')
    end

    it 'has select boxes that work' do
      visit solr_document_path('1')

      expect(page).to have_css('.embedded-items')

      within '.current-document' do
        check 'Select'
      end

      expect(page).to have_css '[data-behavior="recent-selections"]', text: 'Selections (1)'
      expect(page).to have_field 'Selected', checked: true
    end
  end

  describe 'full browse view' do
    it 'is successful' do
      visit solr_document_path('1')

      within '.record-browse-nearby' do
        click_link 'View full page'
      end

      expect(page).to have_css('h1', text: 'Browse related items')
    end
  end
end
