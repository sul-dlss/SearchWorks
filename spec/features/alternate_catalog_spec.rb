# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Alterate catalog results', :js do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
  end

  context 'when on catalog search' do
    it 'draws mini-bento' do
      visit search_catalog_path(q: '1*')
      within '.alternate-catalog' do
        expect(page).to have_css 'h3', text: 'Your search also found results in'
        expect(page).to have_link 'View all Articles+ results'
        expect(page).to have_css '.alternate-catalog-count', text: '4'
        expect(page).to have_link 'Academic journals 1',
                                  href: "/articles?f%5Beds_search_limiters_facet%5D%5B%5D=Direct+access+to+full+text&q=1" \
                                        "%2A&f[eds_publication_type_facet][]=Academic%20journals"
      end
    end
  end

  context 'when on article search' do
    it 'draws mini-bento' do
      visit articles_path(q: '1*')
      within '.alternate-catalog' do
        expect(page).to have_css 'h3', text: 'Your search also found results in'
        expect(page).to have_link 'View all catalog results'
        expect(page).to have_css '.alternate-catalog-count', text: '52'
        expect(page).to have_link 'Book 25', href: "/catalog?q=1%2A&f[format_main_ssim][]=Book"
        expect(page).to have_link 'Image 7', href: "/catalog?q=1%2A&f[format_main_ssim][]=Image"
        expect(page).to have_link 'Database 5', href: "/catalog?q=1%2A&f[format_main_ssim][]=Database"
      end
    end
  end
end
