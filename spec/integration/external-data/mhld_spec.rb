require "spec_helper"

describe "MHLD", feature: true, :"data-integration" => true do
  describe "record view" do
    it "should be present in the location access panel" do
      visit solr_document_path('492502')

      within('.access-panel.panel-library-location') do
        expect(page).to have_css('li.mhld', text: 'Latest issues in CURRENT PERIODICALS; earlier issues in STACKS.')
        expect(page).to have_css('li.mhld.note-highlight', text: /Latest: v\.\d/)
        expect(page).to have_css('li.mhld', text: /Library has: v\.\d/)
      end
    end
  end
  describe "results view", js: true do
    it "should be present in the accordion section" do
      visit search_catalog_path(q: '492502')

      within(first('.document')) do
        expect(page).to have_content('At the library')
        within('.accordion-section.location') do
          find('a.header').click
          expect(page).to have_css('tr th strong', text: 'Current Periodicals')
          expect(page).to have_css('tr th', text: 'Latest issues in CURRENT PERIODICALS; earlier issues in STACKS.')
          expect(page).to have_css('tr td .note-highlight', text: /Latest: v\.\d/)
        end

      end
    end
  end
end
