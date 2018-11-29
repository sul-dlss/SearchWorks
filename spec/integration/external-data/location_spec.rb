require "spec_helper"

describe "Location", feature: true, :"data-integration" => true do
  describe "SAL3" do
    it "items should be pageable" do
      visit solr_document_path('10385184')

      within('.panel-library-location') do
        within('.location table') do
          expect(page).to have_css('i.page')
        end
      end
    end
  end
  describe "ARS" do
    it "should be noncirc for non STK item type" do
      visit solr_document_path('10160087')

      within('.panel-library-location') do
        within(first('.location table')) do
          expect(page).to have_css('i.noncirc', count: 3)
        end
      end
    end
    it "should not be noncirc for non STK item type" do
      visit solr_document_path('10458422')

      within('.panel-library-location') do
        within(first('.location table')) do
          expect(page).not_to have_css('i.noncirc')
        end
      end
    end
  end
  describe "standard item" do
    it "should default w/ an unknown item status" do
      visit solr_document_path('10424524')

      within('.panel-library-location') do
        within(first('.location table')) do
          expect(page).to have_css('i.unknown')
        end
      end
    end
  end
  describe "bound with items" do
    before do
      visit solr_document_path('796463')
    end
    it "should not show request links for requstable libraries" do
      within('.availability') do
        expect(page).not_to have_content('Request')
      end
    end
    it "should show the MARC 590 note in the availability display" do
      within('.location') do
        expect(page).to have_css('.bound-with-note.note-highlight', text: "Copy 1 bound with 1967, pt. 1. 796443(parent record's ckey)")
        expect(page).to have_css('.bound-with-note.note-highlight a', text:"796443")
        click_link '796443'
      end
      expect(page).to have_css('h1', text: /Der Urheberschutz wissenschaftlicher/)
    end
  end
end
