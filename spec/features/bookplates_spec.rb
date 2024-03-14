# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bookplates' do
  describe 'on the record view' do
    it 'displays bookplate data when present' do
      visit solr_document_path('45')

      expect(page).to have_css('h3', text: 'Acquired with support from')
      expect(page).to have_css('.bookplate', count: 2)

      within(first('.bookplate')) do
        expect(page).to have_css('img.mr-3')
        expect(page).to have_css('.media-body a', text: 'Susan and Ruth Sharp Fund')
      end

      within(all('.bookplate').last) do
        expect(page).to have_css('img.mr-3')
        expect(page).to have_css('.media-body a', text: 'The Edgar Amos Boyles Centennial Book Fund')
      end
    end

    it 'does not include the section when there is no bookplate data' do
      visit solr_document_path('44')

      expect(page).to have_no_css('h2', text: 'Acquired with support from')
      expect(page).to have_no_css('.bookplate')
    end
  end

  describe 'search results' do
    let(:masthead_text) do
      'The library resources listed below were acquired with the generous support of this endowed materials fund.'
    end

    it 'displays a masthead with the bookplate data for each individual fund (with correct breadcrumb)' do
      visit solr_document_path('45')

      click_link 'Susan and Ruth Sharp Fund'

      within('.bookplate-fund-masthead') do
        expect(page).to have_css('img')
        expect(page).to have_css('h1', text: 'Susan and Ruth Sharp Fund')
        expect(page).to have_content masthead_text
      end

      within('.constraint') do
        expect(page).to have_css('.filter-name', text: 'Acquired with support from')
        expect(page).to have_css('.filter-value', text: 'Susan and Ruth Sharp Fund')
      end

      expect(page).to have_css('h2', text: '1 catalog result')

      visit solr_document_path('45')

      click_link 'The Edgar Amos Boyles Centennial Book Fund'

      within('.bookplate-fund-masthead') do
        expect(page).to have_css('img')
        expect(page).to have_css('h1', text: 'The Edgar Amos Boyles Centennial Book Fund')
        expect(page).to have_content masthead_text
      end

      within('.constraint') do
        expect(page).to have_css('.filter-name', text: 'Acquired with support from')
        expect(page).to have_css('.filter-value', text: 'The Edgar Amos Boyles Centennial Book Fund')
      end

      expect(page).to have_css('h2', text: '1 catalog result')
    end

    it 'returns a gallery view search result sorted by "new to the Libraries"' do
      visit solr_document_path('45')

      click_link 'Susan and Ruth Sharp Fund'

      expect(page).to have_css('#documents.gallery')
      expect(current_url).to include 'view=gallery'

      expect(current_url).to include 'sort=new-to-libs'
    end
  end
end
