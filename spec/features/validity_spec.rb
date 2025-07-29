# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Site validity' do
  describe 'the home page' do
    before { visit root_path }

    it 'is valid html, including the header and footer' do
      expect(page).to be_valid_html
    end
  end

  describe 'the catalog search results' do
    before { stub_article_service(docs: StubArticleService::SAMPLE_RESULTS) }

    context 'with results' do
      before { visit search_catalog_path f: { access_facet: ['Online'] } }

      it 'is valid html' do
        expect(page).to be_valid_html
      end
    end

    context 'with zero results' do
      before { visit search_catalog_path q: 'sdfsda', search_field: 'search_author' }

      it 'is valid html' do
        expect(page).to be_valid_html
      end
    end
  end

  describe 'the catalog record view page' do
    it 'has an valid view' do
      visit solr_document_path('28')
      expect(page).to be_valid_html
    end

    it 'has an valid view with filmstrips' do
      visit solr_document_path('34')
      expect(page).to be_valid_html
    end
  end

  describe 'the articles index page' do
    before { visit articles_path }

    it 'is valid html' do
      expect(page).to be_valid_html
    end
  end

  describe 'the articles' do
    before { stub_article_service(docs: StubArticleService::SAMPLE_RESULTS) }

    it 'has an accessible search results page' do
      visit articles_path q: 'frog'
      expect(page).to be_valid_html
    end

    it 'has an accessible zero results page' do
      visit articles_path(q: 'Kittens', f: { 'eds_subject_topic_facet' => ['Abc'] }, search_field: 'search')
      expect(page).to be_valid_html
    end
  end

  describe 'the selections page' do
    before do
      visit '/selections'
    end

    it 'is valid html' do
      expect(page).to be_valid_html
    end
  end

  describe 'the course reserves page' do
    before do
      create(:reg_course)
      visit course_reserves_path
    end

    it 'is valid html' do
      expect(page).to be_valid_html
    end
  end

  describe 'the database page' do
    before do
      visit databases_path
    end

    it 'is valid html' do
      expect(page).to be_valid_html
    end
  end
end
