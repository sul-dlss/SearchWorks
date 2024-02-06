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
      expect(page).to have_no_css('td', text: 'IHG', visible: true)
      click_button 'show all'
      expect(page).to have_css('td', text: 'IHG', visible: true)
    end
  end
end
