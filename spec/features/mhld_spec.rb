require "spec_helper"

describe "MHLD", feature: true do
  describe "record view" do
    it "should be present in the location access panel" do
      visit catalog_path('10')

      within('[data-hours-route="/hours/CHEMCHMENG"]') do
        expect(page).to have_css('.location-name', text: 'Current Periodicals')
        expect(page).to have_css('li.mhld.public-note', text: 'public note2')
        expect(page).to have_css('li.mhld', text: 'Latest: latest received2')
        expect(page).to have_css('li.mhld', text: 'Library has: library has2')
      end
      within('[data-hours-route="/hours/GREEN"]') do
        expect(page).to have_css('.location-name', text: 'Stacks')
        expect(page).to have_css('li.mhld.public-note', text: 'public note3')
        expect(page).to have_css('li.mhld', text: 'Latest: latest received3')
        expect(page).to have_css('li.mhld', text: 'Library has: library has3')
      end
    end
  end
  describe "results view", js: true do
    it "should be present in the accordion section" do
      visit catalog_index_path(q: '10')

      within(first('.document')) do
        expect(page).to have_content('At the library')
        within('.accordion-section.location') do
          find('a.header').click
          expect(page).to have_css('tr th strong', text: 'Current Periodicals')
          expect(page).to have_css('tr th .public-note', text: 'public note1')
          expect(page).to have_css('tr th .public-note', text: 'public note2')
          expect(page).to have_css('tr th .public-note', text: 'public note3')
          expect(page).to have_css('tr td', text: 'Latest: latest received1')
          expect(page).to have_css('tr td', text: 'Latest: latest received2')
          expect(page).to have_css('tr td', text: 'Latest: latest received3')
        end
      end
    end
  end
end