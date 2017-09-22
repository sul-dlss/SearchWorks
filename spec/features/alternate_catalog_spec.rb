# frozen_string_literal: true

require 'spec_helper'

feature 'Alterate catalog results', js: true do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
  end

  scenario 'on catalog search' do
    visit search_catalog_path(q: '1*')
    wait_for_ajax
    within '.alternate-catalog' do
      expect(page).to have_css 'h3', text: 'YOUR SEARCH ALSO FOUND RESULTS IN'
      expect(page).to have_css 'a.btn', text: 'See 4 article+ results'
      expect(page).to have_css(
        'a[href="/articles?f%5Beds_search_limiters_facet%5D%5B%5D=Direct+access+to+full+text&q=1'\
          '%2A&f[eds_publication_type_facet][]=Academic%20journals"]',
        text: 'Academic journals (1)'
      )
    end
  end

  scenario 'on article search' do
    visit articles_path(q: '1*')
    wait_for_ajax
    within '.alternate-catalog' do
      expect(page).to have_css 'h3', text: 'YOUR SEARCH ALSO FOUND RESULTS IN'
      expect(page).to have_css 'a.btn', text: 'See 29 catalog results'
      expect(page).to have_css 'a[href="/catalog?q=1%2A&f[format_main_ssim][]=Book"]', text: 'Book (9)'
      expect(page).to have_css 'a[href="/catalog?q=1%2A&f[format_main_ssim][]=Image"]', text: 'Image (7)'
      expect(page).to have_css 'a[href="/catalog?q=1%2A&f[format_main_ssim][]=Database"]', text: 'Database (4)'
      expect(page).to have_css 'a[href="/catalog?q=1%2A&f[format_main_ssim][]=Newspaper"]', text: 'Newspaper (4)'
      expect(page).to have_css 'a[href="/catalog?q=1%2A&f[format_main_ssim][]=Video"]', text: 'Video (4)'
    end
  end
end
