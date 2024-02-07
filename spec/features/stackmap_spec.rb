require 'rails_helper'

RSpec.describe 'StackMap View' do
  it 'Displays the map', :js do
    visit search_catalog_path f: { format: ['Book'] }
    within '#view-type-dropdown' do
      click_button 'View'
      click_link 'gallery'
    end

    within '[data-doc-id="10"]' do
      click_button 'Preview'
    end
    within '.preview-container' do
      click_button "Check availability"
      click_link 'Find it', match: :first
    end

    expect(page).to have_content "Call number HF1604 .G368 2024 is located in Green Library, Lower level of the East Wing."
    expect(page).to have_css ".leaflet-container"
  end
end
