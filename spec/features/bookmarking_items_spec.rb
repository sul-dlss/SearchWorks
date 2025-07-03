# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Bookmarking Items' do
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

      within(first('.document')) do
        find('.toggle-bookmark-label').click
      end

      within(all('.document').last) do
        find('.toggle-bookmark-label').click
      end

      visit bookmarks_path

      expect(page).to have_css('.active .bookmark-counter', text: '2')
      expect(page).to have_css('.bookmark-counter', text: '0')
      within "#documents" do
        expect(page).to have_css("h3.index_title a", count: 2)
      end

      click_link 'Cite'

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
      expect(page).to have_css('.bookmark-counter', text: '0')
      expect(page).to have_content "You have no selections"
    end
  end
end
