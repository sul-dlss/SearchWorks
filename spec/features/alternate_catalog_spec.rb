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
        expect(page).to have_css 'h2', text: 'Looking for more?'
        expect(page).to have_link 'View Articles+ results'
        expect(page).to have_css '.alternate-catalog-count', text: '4'
      end
    end

    it 'draws mini-mini-bento' do
      visit search_catalog_path(q: '1*')
      click_button 'Format'
      within '.mini-mini-bento' do
        expect(page).to have_text 'SearchWorks Articles+'
        expect(page).to have_css '.bento-count', text: '4'
      end
    end
  end

  context 'when on article search' do
    it 'draws mini-bento' do
      visit articles_path(q: '1*')
      within '.alternate-catalog' do
        expect(page).to have_css 'h2', text: 'Looking for more?'
        expect(page).to have_link 'View catalog results'
        expect(page).to have_css '.alternate-catalog-count'
      end
    end

    it 'draws mini-mini-bento' do
      visit articles_path(q: '1*')
      click_button 'Source type'
      within '.mini-mini-bento' do
        expect(page).to have_text 'SearchWorks Catalog'
        expect(page).to have_css '.bento-count', text: '64'
      end
    end
  end

  context 'when on small screens', :responsive, page_width: 700 do
    it 'renders a button that opens mini-bento in a drawer' do
      visit search_catalog_path(q: '1*')
      click_button 'Looking for more?'
      expect(page).to have_css '.offcanvas .alternate-catalog'
    end
  end

  context 'when on medium screens', :responsive, page_width: 800 do
    it 'draws mini-bento in the sidebar' do
      visit search_catalog_path(q: '1*')
      expect(page).to have_css '.sidebar .alternate-catalog'
      expect(page).to have_no_button 'Looking for more?'
    end
  end

  context 'when on extra large screens', :responsive, page_width: 1400 do
    it 'draws mini-bento in the aside' do
      visit search_catalog_path(q: '1*')
      expect(page).to have_css 'aside .alternate-catalog'
      expect(page).to have_no_button 'Looking for more?'
    end
  end
end
