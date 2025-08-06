# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Library Location Access Panel" do
  it "has 1 library location" do
    visit '/view/1'
    expect(page).to have_css('div.panel-library-location', count: 1)
    within "div.panel-library-location" do
      within "div.library-location-heading" do
        expect(page).to have_css('h3', text: 'Earth Sciences Library (Branner)')
      end
    end
  end

  context 'for an title with three locations' do
    let(:lookup_service) do
      instance_double(LiveLookup, records: [
        { item_id: "a9c6236e-bd02-484c-ae0c-b13b32ce6ff9", due_date: nil, status: 'Available', is_available: true, is_requestable_status: false }
      ])
    end

    before do
      allow(LiveLookup).to receive(:new).and_return(lookup_service)
      visit '/view/10'
    end

    it "has 3 library locations", :js do
      pending 'SW4.0 redesign pending.'
      expect(page).to have_css('div.panel-library-location', count: 4)

      # These assertions check that the live-lookup worked:
      expect(page).to have_css('.availability-icon.available')
      expect(page).to have_text('Available')
    end
  end

  describe 'long lists more than 5 callnumbers', :js do
    it 'is truncated with a more link' do
      visit solr_document_path '10'
      expect(page).to have_text 'Availability'
      expect(page).to have_no_css('.callnumber', text: 'MNO', visible: true)
      click_link 'Browse all 6 items'
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

  describe 'when expanding the modal', :js do
    it 'expands the modal to show all items with the expand button' do
      visit '/view/402381'
      click_link 'Expand'

      expect(page).to have_content 'SI 8.9: 29'
      expect(page).to have_content 'N380 .S75 V.73'
    end

    it 'shows public notes' do
      visit solr_document_path '1213958'
      expect(page).to have_content 'Note: Copy 3'
      expect(page).to have_content 'Note: Timoshenko Collection'
      click_link 'Expand'

      within '.availability-modal' do
        expect(page).to have_content 'Note: Copy 3'
        expect(page).to have_content 'Note: Timoshenko Collection'
      end
    end

    it 'expands the modal to just the current library with the "browse all" button' do
      visit '/view/402381'
      click_link 'Browse all 9 items'

      expect(page).to have_content 'N380 .S75 V.73'
      expect(page).to have_no_content 'SI 8.9: 29'
    end

    it 'allows the user to search by call number' do
      visit '/view/402381'
      click_link 'Expand'

      within '.availability-modal' do
        fill_in 'Search items', with: '7'

        expect(page).to have_css('.availability-modal tr:has(mark)', count: 12)

        expect(page).to have_content('20 items | 2 matches').and(have_content('US Federal Documents')).and(have_content('SI 8.9: 7'))
        expect(page).to have_content('9 items | 9 matches').and(have_content('SAL3')).and(have_content('N380 .S75 V.12'))

        fill_in 'Search items', with: '73'

        expect(page).to have_content('20 items | 0 matches').and(have_no_content('US Federal Documents'))
        expect(page).to have_content('9 items | 1 match').and(have_content('SAL3'))

        fill_in 'Search items', with: ''

        expect(page).to have_content 'SI 8.9: 29'
        expect(page).to have_content 'N380 .S75 V.73'
      end
    end

    it 'hides the online availability when searching' do
      visit '/view/10838998'
      click_link 'Expand'
      fill_in 'Search items', with: 'ML'

      within '.availability-modal' do
        expect(page).to have_no_content('MIT Press Direct')
      end
    end
  end
end
