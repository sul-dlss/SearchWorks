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
  end

  context 'when on article search' do
    it 'draws mini-bento' do
      visit articles_path(q: '1*')
      within '.alternate-catalog' do
        expect(page).to have_css 'h2', text: 'Looking for more?'
        expect(page).to have_link 'View catalog results'
        expect(page).to have_css '.alternate-catalog-count', text: '62'
      end
    end
  end
end
