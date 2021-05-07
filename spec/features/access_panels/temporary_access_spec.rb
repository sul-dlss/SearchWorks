# frozen_string_literal: true

require 'spec_helper'

describe 'Temporary Access' do
  it 'renders the access panel for documents with the appropriate data' do
    visit solr_document_path('17')

    within '.metadata-panels' do
      within '.panel.temporary-access' do
        expect(page).to have_css('.card-header h3', text: 'Temporary access')
        expect(page).to have_link('Full text via HathiTrust')
        expect(page).to have_css('.etas-notice', text: /by special arrangement in response/)
      end
    end
  end

  it 'renders the temp access content in results' do
    visit search_catalog_path(q: '17')

    within(first('.document')) do
      within '.results-online-section' do
        expect(page).to have_link('Full text via HathiTrust')
        expect(page).to have_css('.etas-notice', text: /by special arrangement in response/)
      end
    end
  end
end
