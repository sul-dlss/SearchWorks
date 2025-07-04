# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Digital Collections Access Point' do
  before do
    visit root_path
    within '.features' do
      click_link "Digital collections"
    end
  end

  it 'includes the digital collections masthead' do
    within(".search-masthead") do
      expect(page).to have_css('h1', text: 'Digital collections')
      expect(page).to have_css('a', text: 'All digital items')
      expect(page).to have_css('a', text: 'IIIF resources')
      expect(page).to have_css('a', text: 'More about the SDR')
    end
  end
end
