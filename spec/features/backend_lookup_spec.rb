require 'spec_helper'

feature 'Backend lookup', js: true do
  before { visit root_path }
  scenario 'lookup should return additional results on the zero results page' do
    fill_in 'q', with: 'sdfsda'
    select 'Author', from: 'search_field'
    click_button 'Search'

    within(first('.zero-results-list')) do
      expect(page).to have_css('a', text: 'All fields: sdfsda ... found 0 results')
    end
  end

  scenario 'lookup should return additional results on the results page' do
    visit search_catalog_path(
      q: 'statement',
      f: { access_facet: ['Online'] }
    )

    within(first('.zero-results-list')) do
      expect(page).to have_css('a', text: 'Keyword: statement ... found 1 results')
    end
  end
end
