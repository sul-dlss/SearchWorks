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
      expect(page).to have_css('h1', text: 'Stanford digital collections')
      expect(page).to have_css('a', text: 'More information')
      expect(page).to have_css('a', text: 'Submit materials')
    end
  end
end
