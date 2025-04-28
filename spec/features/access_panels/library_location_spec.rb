# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Library Location Access Panel" do
  it "has 1 library location" do
    visit '/view/1'
    expect(page).to have_css('div.panel-library-location', count: 1)
    within "div.panel-library-location" do
      within "div.library-location-heading" do
        expect(page).to have_css('img[src^="/assets/EARTH-SCI"]')
        expect(page).to have_css('div.library-location-heading-text h3', text: 'Earth Sciences Library (Branner)')
      end
    end
  end

  context 'for an title with three locations' do
    let(:lookup_service) do
      instance_double(LiveLookup, as_json: [
        { item_id: "a9c6236e-bd02-484c-ae0c-b13b32ce6ff9", due_date: nil, status: nil, is_available: true, is_requestable_status: false }
      ])
    end

    before do
      allow(LiveLookup).to receive(:new).and_return(lookup_service)
      visit '/view/10'
    end

    it "has 3 library locations", :js do
      expect(page).to have_css('div.panel-library-location', count: 4)

      # These assertions check that the live-lookup worked:
      expect(page).to have_css('.availability-icon.available')
      expect(page).to have_text('Available')
    end
  end

  describe 'long lists more than 5 callnumbers', :js do
    it 'is truncated with a more link' do
      visit solr_document_path '10'
      expect(page).to have_text 'At the library'
      expect(page).to have_no_css('.callnumber', text: 'MNO', visible: true)
      click_button 'show all'
      expect(page).to have_css('.callnumber', text: 'MNO', visible: true)
    end
  end

  context 'when a finding aid is present and items are aeon pageable' do
    before do
      visit solr_document_path '4085177'
    end

    it 'consolidates multiple items to their single base call number' do
      within '.record-panels' do
        expect(page).to have_css('.callnumber', text: 'SC0132', count: 1)
        expect(page).to have_no_css('.callnumber', text: 'SC0132 1997-093 BOX 1')
      end
    end
  end

  context 'when a finding aid is present with both aeon pageable and non-pageable items' do
    before do
      visit solr_document_path '6631609'
    end

    it 'shows the base call number for the aeon pageable items' do
      within '.record-panels' do
        expect(page).to have_css('.callnumber', text: 'SCM0445', count: 1)
        expect(page).to have_no_css('.callnumber', text: 'SCM0445 ACCN 2015-099 HALF BOX 1')
      end
    end

    it 'shows the unconsolidated items with their full call number for items that are not aeon pageable' do
      within '.record-panels' do
        expect(page).to have_css('.callnumber', text: 'ZMS 1688')
        expect(page).to have_css('.callnumber', text: 'ZMS 1688 PRODUCT MANUAL')
        expect(page).to have_css('.callnumber', text: 'ZMS 1688 STRATEGY & TECHNICAL GUIDE')
      end
    end
  end
end
