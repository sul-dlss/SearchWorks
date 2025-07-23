# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dissertation Theses Access Point', :js do
  before do
    visit root_path
    within '.features' do
      click_link 'Theses and dissertations'
    end
  end

  it 'has a custom page title' do
    expect(page).to have_title('Dissertation theses in SearchWorks catalog')
  end
  it 'includes the dissertation/theses masthead' do
    within(".search-masthead") do
      expect(page).to have_css('h1', text: 'Theses and dissertations')
    end
  end

  it 'sets the correct top and other filters' do
    within('.top-filters') do
      expect(page).to have_css('h3', text: 'Stanford student work')
      expect(page).to have_css('a', text: 'Theses & dissertations')
    end

    within('.other-filters') do
      expect(page).to have_css('h3', text: 'Genre')
      expect(page).to have_css('h3', text: 'Date')
    end
  end

  it 'Toggles the Stanford work facet' do
    expect(page).to have_css('#facet_option_stanford_only', visible: :visible)
    # Without the Stanford work filter, there should be 3 results
    expect(page).to have_css('article', count: 3)

    # Check the checkbox to filter by Stanford work
    check "Show Stanford work only"

    # Expect the Stanford work filter to be applied
    expect(page).to have_css('article', count: 1)

    # Uncheck the checkbox to remove the filter
    uncheck "Show Stanford work only"

    # Expect the Stanford work filter to be removed
    expect(page).to have_css('article', count: 3)
  end
end
