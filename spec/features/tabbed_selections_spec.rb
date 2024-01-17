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

  describe 'selections drop down', :js do
    it 'renders a drop down with counts for each type of record selection' do
      visit '/'

      within('#search-subnavbar') do
        click_link 'Selections (7)'

        within('.recent-selections') do
          expect(page).to have_link('Catalog selections (3)')
          expect(page).to have_link('Articles+ selections (4)')
        end
      end
    end
  end

  describe 'selections send to', :js do
    it 'renders export formats' do
      visit '/selections'
      find('#tools-dropdown button').click

      within('#tools-dropdown .dropdown-menu') do
        expect(page).to have_link('email')
        expect(page).to have_link('RefWorks')
        expect(page).to have_link('EndNote')
        expect(page).to have_link('printer')
      end
    end
  end

  describe 'article records' do
    it 'renders selected articles' do
      visit '/selections/articles'

      expect(page).to have_css('.btn', text: '3 catalog items')
      expect(page).to have_css('.btn', text: '4 articles+ items')
      expect(page).to have_css('.document', count: 4)
    end

    it 'paginates articles' do
      visit '/selections/articles?per_page=2'
      expect(page).to have_css('.document-counter', text: '1.')
      expect(page).to have_css('.document-counter', text: '2.')
      expect(page).to have_css('#citeLink', text: '1 - 2')

      visit '/selections/articles?per_page=2&page=2'
      expect(page).to have_css('.document-counter', text: '3.')
      expect(page).to have_css('.document-counter', text: '4.')
      expect(page).to have_css('#citeLink', text: '3 - 4')
    end
  end

  describe 'catalog records' do
    it 'renders selected catalog documents' do
      visit '/selections'

      expect(page).to have_css('.btn', text: '3 catalog items')
      expect(page).to have_css('.btn', text: '4 articles+ items')
      expect(page).to have_css('.document', count: 3)
    end
  end

  describe 'clearing lists' do
    it 'clears article lists desktop' do
      visit '/selections/articles'

      # first .sort-and-per-page is desktop layout
      within(first('.sort-and-per-page')) do
        click_link 'Clear list'
      end

      expect(page).to have_css('.btn', text: '3 catalog items')
      expect(page).to have_css('.btn', text: '0 articles+ items')
    end

    it 'clears catalog lists' do
      visit '/selections'

      # first .sort-and-per-page is desktop layout
      within(first('.sort-and-per-page')) do
        click_link 'Clear list'
      end

      expect(page).to have_css('.btn', text: '0 catalog items')
      expect(page).to have_css('.btn', text: '4 articles+ items')
    end

    it 'clears both lists' do
      visit '/selections'

      expect(page).to have_css('.btn', text: '3 catalog items')
      expect(page).to have_css('.btn', text: '4 articles+ items')

      within('#search-subnavbar .recent-selections') do
        click_link 'Clear all lists'
      end

      expect(page).to have_css('.btn', text: '0 catalog items')
      expect(page).to have_css('.btn', text: '0 articles+ items')
    end
  end
end
