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
end
