# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Bookmarking Items', :js do
  let(:oclc_citation) { instance_double(Citations::OclcCitation) }

  before do
    allow(Citations::OclcCitation).to receive(:new).and_return(oclc_citation)
    allow(oclc_citation).to receive_messages(
      citations_by_oclc_number: { '12345' => { 'mla' => '<p class="citation_style_MLA">MLA Citation</p>' } }
    )
  end

  context 'with bookmarks', :js do
    it 'renders the page' do
      visit search_catalog_path f: { format: ["Book"] }, view: "default"

      # Add one document to saved records
      within(first('.document')) do
        click_button 'Save record'
      end

      expect(page).to have_content('Saved to bookmarks')

      # Add another document to saved records
      within(first('.document:nth-child(2)')) do
        click_button 'Save record'
      end

      expect(page).to have_content('Saved to bookmarks')

      # Remove the second document from saved records
      within(first('.document:nth-child(2)')) do
        click_button('Remove from saved records')
      end

      expect(page).to have_content('Removed from bookmarks')

      # Add another document to saved records
      within(all('.document').last) do
        click_button 'Save record'
      end

      expect(page).to have_content('Saved to bookmarks')

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
