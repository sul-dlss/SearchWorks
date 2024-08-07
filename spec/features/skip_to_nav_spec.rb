# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Skip-to Navigation" do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
  end

  scenario "has skip-to navigation links to search field and main container in home page" do
    visit root_url
    within "#skip-link" do
      expect(page).to have_css("a[href='#search_field']", text: "Skip to search")
      expect(page).to have_css("a[href='#main-container']", text: "Skip to main content")
    end
  end

  scenario "has skip-to navigation links to search field, main container and records in results page" do
    visit root_url
    fill_in "q", with: "20"
    click_button 'search'

    within "#skip-link" do
      expect(page).to have_css("a[href='#search_field']", text: "Skip to search")
      expect(page).to have_css("a[href='#main-container']", text: "Skip to main content")
      expect(page).to have_css("a[href='#documents']", text: "Skip to first result")
    end
  end

  scenario "has skip-to navigation links to search field, main container and records in selections page", :js do
    visit root_path
    fill_in 'q', with: '20'
    find('button#search').click
    find_by_id('toggle-bookmark_20').set(true)
    visit bookmarks_path

    within "#skip-link" do
      expect(page).to have_css("a[href='#search_field']", text: "Skip to search")
      expect(page).to have_css("a[href='#main-container']", text: "Skip to main content")
      expect(page).to have_css("a[href='#documents']", text: "Skip to first result")
    end
  end

  scenario "has skip-to navigation links to search field, main container and records in record view page" do
    visit solr_document_path 20

    within "#skip-link" do
      expect(page).to have_css("a[href='#search_field']", text: "Skip to search")
      expect(page).to have_css("a[href='#document']", text: "Skip to main content")
    end
  end

  scenario "has skip-to navigation links to form in advanced search page" do
    visit blacklight_advanced_search_engine.advanced_search_path

    within "#skip-link" do
      expect(page).to have_css("a[href='#advanced-search-form']", text: "Skip to advanced search form")
    end
  end
end
