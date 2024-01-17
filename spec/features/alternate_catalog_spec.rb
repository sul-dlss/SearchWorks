# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Alterate catalog results', :js do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
  end

  scenario 'on catalog search' do
    expect(LibGuidesApi).to receive(:fetch).and_return([])

    visit search_catalog_path(q: '1*')
    wait_for_ajax
    within '.alternate-catalog' do
      expect(page).to have_css 'h3', text: 'Your search also found results in'
      expect(page).to have_css 'a.btn', text: 'See 4 article+ results'
      expect(page).to have_css(
        'a[href="/articles?f%5Beds_search_limiters_facet%5D%5B%5D=Direct+access+to+full+text&q=1'\
          '%2A&f[eds_publication_type_facet][]=Academic%20journals"]',
        text: 'Academic journals (1)'
      )

      expect(page).to have_no_css('.lib-guides-alternate-catalog', visible: :visible)
    end
  end

  scenario 'LibGuides Results' do
    expect(LibGuidesApi).to receive(:fetch).and_return([{ name: 'Guide 1', url: 'https://example.com/1' }])

    visit search_catalog_path(q: '1*')
    wait_for_ajax
    within '.alternate-catalog' do
      expect(page).to have_css('.lib-guides-alternate-catalog', visible: :visible)
      within('.lib-guides-alternate-catalog') do
        expect(page).to have_css('ol li', count: 1)

        expect(page).to have_link('Guide 1', href: 'https://example.com/1')
      end
    end
  end

  scenario 'on article search' do
    expect(LibGuidesApi).to receive(:fetch).and_return([])

    visit articles_path(q: '1*')
    wait_for_ajax
    within '.alternate-catalog' do
      expect(page).to have_css 'h3', text: 'Your search also found results in'
      expect(page).to have_css 'a.btn', text: 'See 30 catalog results'
      expect(page).to have_css 'a[href="/catalog?q=1%2A&f[format_main_ssim][]=Book"]', text: 'Book (10)'
      expect(page).to have_css 'a[href="/catalog?q=1%2A&f[format_main_ssim][]=Image"]', text: 'Image (7)'
      expect(page).to have_css 'a[href="/catalog?q=1%2A&f[format_main_ssim][]=Database"]', text: 'Database (4)'
      expect(page).to have_css 'a[href="/catalog?q=1%2A&f[format_main_ssim][]=Newspaper"]', text: 'Newspaper (4)'
      expect(page).to have_css 'a[href="/catalog?q=1%2A&f[format_main_ssim][]=Video"]', text: 'Video (4)'

      expect(page).to have_no_css('.lib-guides-alternate-catalog', visible: :visible)
    end
  end
end
