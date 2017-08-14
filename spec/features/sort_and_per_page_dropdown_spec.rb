require 'spec_helper'

describe 'Sort and per page toolbar', js: true, feature: true do
  describe 'View dropdown' do
    before do
      visit root_path
      fill_in 'q', with: ''
      click_button 'search'
    end

    it 'should display active icon on the current active view' do
      within '#sortAndPerPage' do
        page.find('button.btn.btn-sul-toolbar', text: 'View').click

        expect(page).to have_css('a.view-type-list i.active-icon')
      end

      visit search_catalog_path(q: '', view: 'gallery', search_field: 'search')

      within '#sortAndPerPage' do
        page.find('button.btn.btn-sul-toolbar', text: 'View').click

        expect(page).not_to have_css('a.view-type-list i.active-icon')

        expect(page).to have_css('a.view-type-gallery i.active-icon')
      end
    end
  end

  describe 'Sort dropdown' do
    before do
      visit root_path
      fill_in 'q', with: ''
      click_button 'search'
    end

    it 'should display default correctly' do
      within '#sortAndPerPage' do
        expect(page).to have_css('button.btn.btn-sul-toolbar', text: 'Sort by relevance', visible: true)
      end
    end

    it 'should change to current sort' do
      within '#sortAndPerPage' do
        expect(page).to_not have_css('button.btn.btn-sul-toolbar', text: 'Sort by author', visible: true)
        page.find('button.btn.btn-sul-toolbar', text: 'Sort by relevance').click
        within 'a', text: 'relevance' do
          expect(page).to have_css('i.active-icon')
        end
        click_link 'author'
        page.find('button.btn.btn-sul-toolbar', text: 'Sort by author').click
        within 'a', text: 'relevance' do
          expect(page).to_not have_css('i.active-icon')
        end
        within 'a', text: 'author' do
          expect(page).to have_css('i.active-icon')
        end
        expect(page).to have_css('button.btn.btn-sul-toolbar', text: 'Sort by author', visible: true)
      end
    end
  end

  describe 'Per page dropdown' do
    before do
      visit root_path
      fill_in 'q', with: ''
      click_button 'search'
    end

    it 'should display active icon on the current active per page' do
      within '#sortAndPerPage' do
        page.find('button.btn.btn-sul-toolbar', text: '20 per page').click
        within 'a', text: '20' do
          expect(page).to have_css('i.active-icon')
        end
        page.find('#per_page-dropdown ul li a', text: '50').click
        page.find('button.btn.btn-sul-toolbar', text: '50 per page').click
        within 'a', text: '20' do
          expect(page).to_not have_css('i.active-icon')
        end
        within 'a', text: '50' do
          expect(page).to have_css('i.active-icon')
        end
      end
    end
  end

  describe 'Article search' do
    before do
      stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
      visit articles_path q: 'my search'
    end
    it 'has a sort dropdown' do
      within '#sort-dropdown' do
        expect(page).to have_css('button.btn.btn-sul-toolbar', text: 'Sort by relevance')
      end
    end
    it 'sort dropdown brings up options' do
      within '#sort-dropdown' do
        page.find('button.btn.btn-sul-toolbar').click
        expect(page).to have_css('a', text: 'relevance', visible: true)
        expect(page).to have_css('a', text: 'date (most recent)', visible: true)
        expect(page).to have_css('a', text: 'date (oldest)', visible: true)
      end
    end
    it 'has a per page dropdown' do
      within '#per_page-dropdown' do
        expect(page).to have_css('button.btn.btn-sul-toolbar', text: 'per page')
      end
    end
    it 'per page dropdown brings up options' do
      within '#per_page-dropdown' do
        page.find('button.btn.btn-sul-toolbar').click
        expect(page).to have_css('a', text: '10 per page', visible: true)
        expect(page).to have_css('a', text: '20 per page', visible: true)
        expect(page).to have_css('a', text: '50 per page', visible: true)
        expect(page).to have_css('a', text: '100 per page', visible: true)
      end
    end
  end
end
