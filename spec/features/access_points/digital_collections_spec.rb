# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Digital Collections Access Point', :js do
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

  it 'has the facet options for digital collections' do
    within('.facet-options') do
      expect(page).to have_text('Show collections only')
      expect(page).to have_text('Show collections and individual items')
    end
  end

  it 'Toggles the radio buttons' do
    expect(page).to have_css('article', count: 7)
    expect(page).to have_css('.filter-value', text: 'Digital Collection')

    choose "Show collections and individual items"
    expect(page).to have_css('.filter-value', text: 'Stanford Digital Repository')
    expect(page).to have_css('article', count: 6)

    choose "Show collections only"
    expect(page).to have_css('article', count: 7)
  end
end
