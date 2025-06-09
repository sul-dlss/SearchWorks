# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'StackMap View' do
  before do
    stub_article_service(docs: [])
  end

  it 'Displays the map', :js do
    visit search_catalog_path q: 'Car', f: { format: ['Book'] }
    within '[data-document-id="10"]' do
      click_button "Check availability"
      click_link 'Find it'
    end

    expect(page).to have_content "Call number HF1604 .G368 2024 is located in Green Library, Lower level of the East Wing."
    expect(page).to have_css ".leaflet-container"
  end
end
