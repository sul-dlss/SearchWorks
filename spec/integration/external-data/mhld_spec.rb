require "spec_helper"

describe "MHLD", feature: true, :"data-integration" => true do
  describe "record view" do
    it "should be present in the location access panel" do
      visit catalog_path('492502')

      within('.access-panel.panel-library-location') do
        expect(page).to have_css('li.mhld', text: 'Library has: v.1(1985)-v.20(2012)')
        expect(page).to have_css('li.mhld.public-note', text: 'Latest issues in CURRENT PERIODICALS; earlier issues in STACKS.')
        expect(page).to have_css('li.mhld', text: 'Latest: v.21:no.4 (2013)')
        expect(page).to have_css('li.mhld', text: 'Library has: v.21(2013)-')
      end
    end
  end
  describe "results view", js: true do
    it "should be present in the accordion section" do
      visit catalog_index_path(q: '492502')

      within(first('.document')) do
        expect(page).to have_content('At the library')
        within('.accordion-section.location') do
          find('a.header').click
          expect(page).to have_css('tr td strong', text: 'Current Periodicals')
          expect(page).to have_css('tr td .public-note', text: 'Latest issues in CURRENT PERIODICALS; earlier issues in STACKS.')
          expect(page).to have_css('tr td', text: 'Latest: v.21:no.4 (2013)')
        end
        
      end
    end
  end
end