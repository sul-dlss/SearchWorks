# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Site Accessibility', :js do
  it 'has an accessible home page, including the header and footer' do
    visit root_path
    expect(page).to be_accessible
  end

  context 'with the catalog', skip: "Pending SearchWorks 4.0 designs" do
    before { stub_article_service(docs: StubArticleService::SAMPLE_RESULTS) }

    it 'has an accessible index page' do
      visit search_catalog_path
      expect(page).to be_accessible.within('main')
    end

    it 'has an accessible search results page' do
      visit search_catalog_path f: { access_facet: ['Online'] }
      expect(page).to be_accessible.within('main')
    end

    it 'has an accessible zero results page' do
      visit search_catalog_path(q: 'sdfsda', search_field: 'search_author')
      expect(page).to be_accessible.within('main')
    end
  end

  context 'with articles', skip: "Pending SearchWorks 4.0 designs" do
    before { stub_article_service(docs: StubArticleService::SAMPLE_RESULTS) }

    it 'has an accessible index page' do
      visit articles_path
      expect(page).to be_accessible.within('main')
    end

    it 'has an accessible search results page' do
      visit articles_path q: 'frog'
      expect(page).to be_accessible.within('main')
    end

    it 'has an accessible "more facets" modal' do
      visit articles_path q: 'frog'
      click_button 'Language'
      within '.blacklight-eds_language_facet' do
        click_link 'more'
      end
      expect(page).to have_field 'A-Z Sort'
      expect(page).to be_accessible.within('dialog')
    end

    it 'has an accessible zero results page' do
      visit articles_path(q: 'Kittens', f: { 'eds_subject_topic_facet' => ['Abc'] }, search_field: 'search')
      expect(page).to be_accessible.within('main')
    end
  end

  context 'with a record', skip: "Pending SearchWorks 4.0 designs" do
    it 'has an accessible view' do
      visit solr_document_path('28')
      expect(page).to be_accessible.within('main')
    end

    it 'has an accessible view with filmstrips' do
      visit solr_document_path('34')
      expect(page).to be_accessible.within('main')
    end
  end

  it 'has an accessible bookmarks page', skip: "Pending SearchWorks 4.0 designs" do
    visit bookmarks_path
    expect(page).to be_accessible.within('main')
  end

  it 'has an accessible selections page', skip: "Pending SearchWorks 4.0 designs" do
    visit '/selections'
    expect(page).to be_accessible.within('main')
  end

  it 'has an accessible advanced search page', skip: "Pending SearchWorks 4.0 designs" do
    visit blacklight_advanced_search_engine.advanced_search_path
    expect(page).to be_accessible.within('main')
  end

  it 'has an accessible course reserves page', skip: "Pending SearchWorks 4.0 designs" do
    before do
      create(:reg_course)
      visit course_reserves_path
    end

    expect(page).to be_accessible.within('main')
  end
end
