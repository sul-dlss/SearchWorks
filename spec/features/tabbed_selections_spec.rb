# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tabbed selections UI' do
  let(:user) { User.create!(email: 'example@stanford.edu', password: 'totallysecurepassword') }

  before do
    StubArticleService::SAMPLE_RESULTS.map do |article|
      Bookmark.create!(document_id: article.id, user:, record_type: 'article')
    end

    %w[1 2 3].each do |doc_id|
      Bookmark.create!(document_id: doc_id, user:)
    end

    login_as(user)
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
  end

  describe 'article records' do
    it 'renders selected articles' do
      visit '/selections/articles'

      expect(page).to have_css('.badge', text: '3')
      expect(page).to have_css('.badge', text: '4')
      expect(page).to have_css('.document', count: 4)
    end

    it 'paginates articles' do
      visit '/selections/articles?per_page=2'
      expect(page).to have_css('.document-counter', text: '1.')
      expect(page).to have_css('.document-counter', text: '2.')
      expect(page).to have_content '1 - 2'

      visit '/selections/articles?per_page=2&page=2'
      expect(page).to have_css('.document-counter', text: '3.')
      expect(page).to have_css('.document-counter', text: '4.')
      expect(page).to have_content '3 - 4'
    end
  end

  describe 'catalog records' do
    it 'renders selected catalog documents' do
      visit '/selections'

      expect(page).to have_css('.badge', text: '3')
      expect(page).to have_css('.badge', text: '4')
      expect(page).to have_css('.document', count: 3)
    end
  end
end
