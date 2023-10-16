require 'rails_helper'

RSpec.feature 'Backend lookup', js: true do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
    visit root_path
  end

  scenario 'lookup should return additional results on the zero results page' do
    fill_in 'q', with: 'sdfsda'
    select 'Author', from: 'search_field'
    find_by_id('search').click

    within '.zero-results' do
      expect(page).to have_css('a', text: /sdfsda/)
      expect(page).to have_css('strong', text: /finds 0 results/)
    end
  end

  scenario 'lookup should return additional results on the results page' do
    visit search_catalog_path(
      q: 'statement',
      f: { access_facet: ['Online'] },
      search_field: 'search'
    )

    within '.zero-results' do
      expect(page).to have_css('a', text: /All fields > statement/)
      expect(page).to have_css('strong', text: /finds 1 results/)
    end
  end
end
