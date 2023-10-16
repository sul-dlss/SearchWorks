require 'rails_helper'

RSpec.describe 'Options Facet' do
  it 'renders the eds_search_limiters_facet as checkboxes (behaves like a link)', js: true do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
    visit articles_path(q: 'Example Query')

    expect(page).to have_css('h2', text: 'Search settings')

    within('.facet-options') do
      expect(page).to have_css('label a', text: 'Limiter1')
      expect(page).to have_css('label a', text: 'Limiter2')

      click_link 'Limiter1'
    end

    within('.facet-options') do
      expect(page).to have_checked_field('Limiter1')
    end

    within('.breadcrumb') do
      expect(page).to have_css('.filter-value', text: 'Limiter1')
    end
  end
end
