require 'rails_helper'

RSpec.feature 'Record view', :js do
  it 'should have online books panel with Google links' do
    skip('Google Books API not working under test')
    visit solr_document_path('44')

    within 'div.document' do
      expect(page).to have_css('div.panel-online', visible: true)

      within 'div.panel-online' do
        expect(page).to have_css('div.card-header', visible: true)
        expect(page).to have_css('h3', text: 'Available online', visible: true)
        within('.google-preview') do
          expect(page).to have_css('a.full-view', text: '(Full view)', visible: true)
          expect(page).to have_css("img[src='/assets/gbs_preview_button.gif']")
        end
      end
    end
  end

  scenario 'should have related panel with Google links' do
    skip('Google Books API not working under test')
    visit solr_document_path('10')

    within 'div.document' do
      expect(page).to have_css('div.panel-related', visible: true)

      within 'div.panel-related' do
        expect(page).to have_css('div.card-header', visible: true)
        expect(page).to have_css('h3', text: 'More options', visible: true)
        within('.google-preview') do
          expect(page).to have_css('a.limited-preview', text: '(Limited preview)', visible: true)
          expect(page).to have_css("img[src='/assets/gbs_preview_button.gif']")
        end
      end
    end
  end
end
