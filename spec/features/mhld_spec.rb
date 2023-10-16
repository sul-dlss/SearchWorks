require 'rails_helper'

RSpec.describe "MHLD", :feature do
  describe "record view" do
    it "should be present in the location access panel" do
      visit solr_document_path('10')

      within('[data-hours-route="/hours/CHEMCHMENG"]') do
        expect(page).to have_css('.location-name', text: 'Current periodicals')
        expect(page).to have_css('.mhld', text: 'public note2')
        expect(page).to have_css('.mhld.note-highlight', text: 'Latest: latest received2')
        expect(page).to have_css('.mhld', text: 'Library has: library has2')
      end
      within('[data-hours-route="/hours/GREEN"]') do
        expect(page).to have_css('.location-name', text: 'Stacks')
        expect(page).to have_css('.mhld', text: 'public note3')
        expect(page).to have_css('.mhld.note-highlight', text: 'Latest: latest received3')
        expect(page).to have_css('.mhld', text: 'Library has: library has3')
      end
    end
  end

  describe "results view", :js do
    before do
      stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
    end

    it "should be present in the accordion section" do
      visit search_catalog_path(q: '10')

      within(first('.document')) do
        expect(page).to have_content('Check availability')
        within('.accordion-section.location') do
          find('button.header').click
          expect(page).to have_css('tr th strong', text: 'Current periodicals')
          expect(page).to have_css('tr th', text: 'public note1')
          expect(page).to have_css('tr th', text: 'public note2')
          expect(page).to have_css('tr th', text: 'public note3')
          expect(page).to have_css('tr td .note-highlight', text: 'Latest: latest received1')
          expect(page).to have_css('tr td .note-highlight', text: 'Latest: latest received2')
          expect(page).to have_css('tr td .note-highlight', text: 'Latest: latest received3')
        end
      end
    end
  end
end
