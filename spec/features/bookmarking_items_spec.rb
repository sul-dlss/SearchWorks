# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Bookmarking Items' do
  context 'with bookmarks', :js do
    it 'renders the page' do
      visit search_catalog_path f: { format: ["Book"] }, view: "default"

      within(first('.document')) do
        find('.toggle-bookmark-label').click
      end

      within(all('.document').last) do
        find('.toggle-bookmark-label').click
      end

      visit bookmarks_path

      expect(page).to have_css('h2', text: '2 catalog items')
      expect(page).to have_css('a', text: '0 articles+ items')
      within "#documents" do
        expect(page).to have_css("h3.index_title a", count: 2)
      end

      expect(page).to have_button "Send 1 - 2"
      click_link 'Cite 1 - 2'

      within('.modal-dialog') do
        expect(page).to have_css('div#all')
        click_button 'By citation format'
        expect(page).to have_css('div#biblio')
      end
    end
  end

  context 'with no bookmarks' do
    it "renders the page" do
      visit bookmarks_path
      expect(page).to have_css('h2', text: '0 catalog items')
      expect(page).to have_css('a', text: '0 articles+ items')
      expect(page).to have_css("h3", text: "You have no selections")
    end
  end
end
