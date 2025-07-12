# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Site Accessibility', :js do
  describe 'the home page' do
    before { visit root_path }

    it 'is accessible, including the header and footer' do
      expect(page).to be_accessible
    end
  end

  describe 'the catalog search results' do
    before { stub_article_service(docs: StubArticleService::SAMPLE_RESULTS) }

    context 'with results' do
      before { visit search_catalog_path f: { access_facet: ['Online'] } }

      it 'is accessible' do
        expect(page).to be_accessible.within('main')
      end
    end

    context 'with zero results', skip: "Contrast issue for start-chat" do
      before { visit search_catalog_path q: 'sdfsda', search_field: 'search_author' }

      it 'is accessible' do
        expect(page).to be_accessible.within('main')
      end
    end
  end

  describe 'the catalog record view page' do
    it 'has an accessible view' do
      visit solr_document_path('28')
      expect(page).to be_accessible.within('main')
    end

    it 'has an accessible view with filmstrips', skip: "Pending SearchWorks 4.0 designs" do
      visit solr_document_path('34')
      expect(page).to be_accessible.within('main')
    end
  end

  describe 'advanced search', :js do
    it 'has an accessible view' do
      visit advanced_search_path
      expect(page).to be_accessible.within('main')
    end
  end

  describe 'the articles index page' do
    before { visit articles_path }

    it 'is accessible' do
      expect(page).to be_accessible.within('main')
    end
  end

  describe 'the articles' do
    before { stub_article_service(docs: StubArticleService::SAMPLE_RESULTS) }

    it 'has an accessible search results page' do
      visit articles_path q: 'frog'
      expect(page).to be_accessible.within('main')
    end

    it 'has an accessible "more facets" modal' do
      visit articles_path q: 'frog'
      click_button 'Show all filters'
      click_button 'Language'
      within '.blacklight-eds_language_facet' do
        click_link 'Browse all'
      end
      expect(page).to have_field 'A-Z Sort'
      expect(page).to be_accessible.within('dialog')
    end

    it 'has an accessible zero results page' do
      visit articles_path(q: 'Kittens', f: { 'eds_subject_topic_facet' => ['Abc'] }, search_field: 'search')
      expect(page).to be_accessible.within('main')
    end
  end

  describe 'the selections page' do
    before do
      visit '/selections'
    end

    it 'is accessible' do
      expect(page).to be_accessible.within('main')
    end
  end

  it 'has an accessible advanced search page', skip: "Pending SearchWorks 4.0 designs" do
    visit blacklight_advanced_search_engine.advanced_search_path
    expect(page).to be_accessible.within('main')
  end

  describe 'the course reserves page' do
    before do
      create(:reg_course)
      visit course_reserves_path
    end

    it 'is accessible' do
      expect(page).to be_accessible.within('main')
    end
  end

  describe 'the database page' do
    before do
      visit databases_path
    end

    it 'is accessible' do
      expect(page).to be_accessible.within('main')
    end
  end
end
