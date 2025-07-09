# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Bookmarking Items', :js do
  let(:oclc_citation) { instance_double(Citations::OclcCitation) }
  let(:user) { User.create!(email: 'example@stanford.edu', password: 'totallysecurepassword') }

  before do
    allow(Citations::OclcCitation).to receive(:new).and_return(oclc_citation)
    allow(oclc_citation).to receive_messages(
      citations_by_oclc_number: { '12345' => { 'mla' => '<p class="citation_style_MLA">MLA Citation</p>' } }
    )
    login_as(user)
  end

  describe 'adding and removing bookmarks on the search page' do
    it 'renders the page' do
      visit search_catalog_path f: { format_hsim: ["Book"] }, view: "default"

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

      expect(page).to have_css('.active .bookmark-counter', text: '2')
      expect(page).to have_css('.bookmark-counter', text: '0')
      within "#documents" do
        expect(page).to have_css("h3.index_title a", count: 2)
      end
    end
  end

  describe 'removing bookmarks from the bookmarks page' do
    before do
      %w[1 2 3].each do |id|
        document = SolrDocument.new(id:)
        Bookmark.create!(document:, user:)
      end

      visit bookmarks_path
    end

    it 'renders the page' do
      expect(page).to have_css('.active .bookmark-counter', text: '3')
      expect(page).to have_css('.bookmark-counter', text: '0')
      within "#documents" do
        expect(page).to have_css("article", count: 3)
      end
      # Remove the second document from saved records
      within(first('.document:nth-child(2)')) do
        click_button('Remove from saved records')
      end

      expect(page).to have_content('Removed from bookmarks')

      expect(page).to have_css('.active .bookmark-counter', text: '2')
      expect(page).to have_css('.bookmark-counter', text: '0')
      within "#documents" do
        expect(page).to have_css("article", count: 2)
      end
    end
  end

  describe 'the cite modal' do
    before do
      %w[1 2 3].each do |id|
        document = SolrDocument.new(id:)
        Bookmark.create!(document:, user:)
      end

      visit bookmarks_path
    end

    it 'renders the page' do
      within('.bookmark-toolbar') do
        expect(page).to have_link 'Email'
        expect(page).to have_button 'Print'
        click_link 'Cite'
      end

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
