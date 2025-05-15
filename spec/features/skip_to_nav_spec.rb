# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Skip-to Navigation" do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
  end

  scenario "has skip-to navigation links to search field and main container in home page" do
    visit root_url
    within "#skip-link" do
      expect(page).to have_link "Skip to search", href: '#search_field'
      expect(page).to have_link "Skip to main content", href: '#main-container'
    end
  end

  scenario "has skip-to navigation links to search field, main container and records in results page" do
    visit root_url
    fill_in "q", with: "20"
    click_button 'search'

    within "#skip-link" do
      expect(page).to have_link "Skip to search", href: '#search_field'
      expect(page).to have_link "Skip to main content", href: '#main-container'
      expect(page).to have_link "Skip to first result", href: '#documents'
    end
  end

  scenario "has skip-to navigation links to search field, main container and records in selections page", :js do
    visit root_path
    fill_in 'q', with: '20'
    click_button 'search'

    expect(page).to have_css("article[data-document-id='20']")
    within '[data-document-id="20"]' do
      find('input.toggle-bookmark[type="checkbox"]').set(true)
      expect(page).to have_content 'Selected'
    end

    visit bookmarks_path

    within "#skip-link" do
      expect(page).to have_link "Skip to search", href: '#search_field'
      expect(page).to have_link "Skip to main content", href: '#main-container'
      expect(page).to have_link "Skip to first result", href: '#documents'
    end
  end

  scenario "has skip-to navigation links to search field, main container and records in record view page" do
    visit solr_document_path 20

    within "#skip-link" do
      expect(page).to have_link "Skip to search", href: '#search_field'
      expect(page).to have_link "Skip to main content", href: '#document'
    end
  end

  scenario "has skip-to navigation links to form in advanced search page" do
    visit blacklight_advanced_search_engine.advanced_search_path

    within "#skip-link" do
      expect(page).to have_link "Skip to advanced search form", href: '#advanced-search-form'
    end
  end
end
