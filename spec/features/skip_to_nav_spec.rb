require 'spec_helper'

feature "Skip-to Navigation" do

  scenario "should have skip-to navigation links to search field and main container in home page" do
    visit root_url
    within "#skip-link" do
      expect(page).to have_css("a[href='#search_field']", text: "Skip to search")
      expect(page).to have_css("a[href='#main-container']", text: "Skip to main content")
    end
  end

  scenario "should have skip-to navigation links to search field, main container and records in results page" do
    visit root_url
    fill_in "q", with: "20"
    click_button 'search'

    within "#skip-link" do
      expect(page).to have_css("a[href='#search_field']", text: "Skip to search")
      expect(page).to have_css("a[href='#main-container']", text: "Skip to main content")
      expect(page).to have_css("a[href='#documents']", text: "Skip to first result")
    end
  end

  scenario "should have skip-to navigation links to search field, main container and records in selections page", js: true do
    visit root_path
    fill_in 'q', with: '20'
    find('button#search').trigger('click')
    find(:css, '#toggle_bookmark_20').set(true)
    visit selections_path

    within "#skip-link" do
      expect(page).to have_css("a[href='#search_field']", text: "Skip to search")
      expect(page).to have_css("a[href='#main-container']", text: "Skip to main content")
      expect(page).to have_css("a[href='#documents']", text: "Skip to first result")
    end
  end

  scenario 'places focus on traditionally non-focusable elements', js: true do
    visit root_path

    within '#skip-link' do
      find('a[href="#main-container"]', text: 'Skip to main content').trigger('click')
      active_element = page.evaluate_script('$(document.activeElement).attr("id")')
      expect(active_element).to eq 'main-container'
    end
  end

  scenario "should have skip-to navigation links to search field, main container and records in record view page" do
    visit solr_document_path 20

    within "#skip-link" do
      expect(page).to have_css("a[href='#search_field']", text: "Skip to search")
      expect(page).to have_css("a[href='#document']", text: "Skip to main content")
    end
  end

  scenario "should have skip-to navigation links to form in advanced search page" do
    visit advanced_search_path

    within "#skip-link" do
      expect(page).to have_css("a[href='#advanced-search-form']", text: "Skip to advanced search form")
    end
  end

end
