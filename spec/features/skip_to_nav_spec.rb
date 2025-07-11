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

  describe 'The selections page', :js do
    context 'when the user has a saved item' do
      before do
        visit root_path
        fill_in 'q', with: '20'
        click_button 'search'

        within '[data-document-id="20"]' do
          click_button 'Save record'
        end
        expect(page).to have_content('Record saved') # rubocop:disable RSpec/ExpectInHook

        visit bookmarks_path
      end

      it "has skip-to navigation links to search field, main container and records" do
        within "#skip-link" do
          expect(page).to have_link "Skip to search", href: '#search_field', visible: :all
          expect(page).to have_link "Skip to main content", href: '#main-container', visible: :all
          expect(page).to have_link "Skip to first result", href: '#documents', visible: :all
        end
      end
    end
  end

  scenario "has skip-to navigation links to search field, main container and records in record view page" do
    visit solr_document_path 20

    within "#skip-link" do
      expect(page).to have_link "Skip to search", href: '#search_field'
      expect(page).to have_link "Skip to main content", href: '#main-container'
    end
  end

  scenario "has skip-to navigation links to form in advanced search page" do
    visit blacklight_advanced_search_engine.advanced_search_path

    within "#skip-link" do
      expect(page).to have_link "Skip to advanced search form", href: '#advanced-search-form'
    end
  end
end
