require 'spec_helper'

feature 'Backend lookup', js: true do
  before { visit root_path }
  scenario 'lookup should return additional results on the zero results page' do
    fill_in 'q', with: 'sdfsda'
    select 'Author', from: 'search_field'
    find('#search').trigger('click')

    within '.zero-results' do
      expect(page).to have_css('a', text: /sdfsda/)
      expect(page).to have_css('strong', text: /found 0 results/)
    end
  end

  scenario 'lookup should return additional results on the results page' do
    visit search_catalog_path(
      q: 'statement',
      f: { access_facet: ['Online'] }
    )

    within '.zero-results' do
      expect(page).to have_css('a', text: /Keyword > statement/)
      expect(page).to have_css('strong', text: /found 1 results/)
    end
  end
end
