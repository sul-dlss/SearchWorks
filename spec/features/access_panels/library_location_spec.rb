require 'rails_helper'

RSpec.feature "Library Location Access Panel" do
  scenario "should have 1 library location" do
    visit '/view/1'
    expect(page).to have_css('div.panel-library-location', count: 1)
    within "div.panel-library-location" do
      within "div.library-location-heading" do
        expect(page).to have_css('img[src^="/assets/EARTH-SCI"]')
        expect(page).to have_css('div.library-location-heading-text h3', text: 'Earth Sciences Library (Branner)')
      end
    end
  end

  scenario "should have 3 library locations" do
    visit '/view/10'
    expect(page).to have_css('div.panel-library-location', count: 4)
  end

  feature 'long lists should be truncated', js: true do
    scenario 'items with more than 5 callnumbers should be truncated with a more link' do
      visit solr_document_path '10'
      expect(page).not_to have_css('td', text: 'IHG', visible: true)
      click_button 'show all'
      expect(page).to have_css('td', text: 'IHG', visible: true)
    end
  end
end
