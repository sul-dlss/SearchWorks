# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Search Results Page" do
  scenario "vernacular title" do
    visit search_catalog_path(q: 'id:11')

    within(first('.document')) do
      expect(page).to have_css('h3', text: "Amet ad & adipisicing ex mollit pariatur minim dolore.")
      expect(page).to have_css('div', text: 'Currently, to obtain more information from the weakness of the resultant pain.')
    end
  end

  context 'when there are many results' do
    before do
      visit search_catalog_path f: { access_facet: ['Online'] }
    end

    it 'draws the page' do
      expect(page).to have_title "Search for Access: Online in SearchWorks catalog"

      within('ul.pagination') do
        expect(page).to have_link 'Previous'
      end
    end
  end

  context 'when searching with facets and a query' do
    before do
      visit search_catalog_path f: { access_facet: ['Online'] }, q: 'broccoli'
    end

    it 'draws the page' do
      expect(page).to have_title "broccoli, Access: Online"
    end
  end

  context 'when performing a blank search' do
    before do
      visit search_catalog_path q: ''
    end

    it 'uses the correct page title without a joiner' do
      expect(page).to have_title "SearchWorks catalog"
    end
  end

  context 'with a library filter applied' do
    before do
      visit search_catalog_path f: { library: ['HILA'] }
    end

    it 'uses the friendly library name rather than the code' do
      expect(page).to have_title "Library: Hoover Institution Library & Archives"
    end
  end

  context 'with a library filter and search term applied' do
    before do
      visit search_catalog_path f: { library: ['HILA'] }, q: 'book'
    end

    it 'uses the friendly library name rather than the code' do
      expect(page).to have_title "book, Library: Hoover Institution Library & Archives"
    end
  end

  context 'when clicking clear all' do
    it 'takes the user to a blank search' do
      visit search_catalog_path f: { access_facet: ['Online'] }, q: 'book'
      click_link 'Clear all'

      expect(page).to have_content 'Search tips'
      expect(page).to have_content 'Featured resources'
      expect(page).to have_css '.sidebar'
      expect(page).to have_no_css '.search-area-image-bg'
      expect(page.current_url).not_to include(/[q|f]=/)
    end
  end

  context 'with a collection with a finding aid' do
    before do
      visit search_catalog_path(q: '11966809')
    end

    it 'flags the collection' do
      expect(page).to have_css '.badge.text-palo-alto-dark', text: 'Archival Collections at Stanford'
    end
  end

  context 'with a digital collection' do
    before do
      visit search_catalog_path(q: '29')
    end

    it 'flags the collection' do
      expect(page).to have_css '.badge.text-secondary', text: 'Collection'
    end
  end
end
