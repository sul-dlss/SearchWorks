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
      expect(page).to have_title "SearchWorks catalog, Access: Online"

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
      expect(page).to have_title "SearchWorks catalog, broccoli, Access: Online"
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
end
