# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Backend lookup', :js do
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
      expect(page).to have_css('span', text: /finds 0 results/)
    end
  end

  scenario 'lookup should return additional results on the results page' do
    visit search_catalog_path(
      q: 'Lorem aute dolor',
      f: { access_facet: ['Online'] },
      search_field: 'search'
    )

    within '.zero-results' do
      expect(page).to have_css('a', text: /All fields > Lorem aute dolor/)
      expect(page).to have_css('span', text: /finds 2 results/)
    end
  end
end
