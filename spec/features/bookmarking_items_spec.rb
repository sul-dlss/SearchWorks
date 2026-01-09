# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Bookmarking Items', :js do
  let(:user) { User.create!(email: 'example@stanford.edu', password: 'totallysecurepassword') }

  before do
    login_as(user)
  end

  describe 'adding and removing bookmarks on the search page' do
    it 'renders the page' do
      visit search_catalog_path f: { format_hsim: ["Book"] }, view: "default"

      # Add one document to saved records
      within(first('.document')) do
        find('.toggle-bookmark').click
      end

      expect(page).to have_content('Record saved')

      # Add another document to saved records
      within(first('.document:nth-child(2)')) do
        find('.toggle-bookmark').click
      end

      expect(page).to have_content('Record saved')

      # Remove the second document from saved records
      within(first('.document:nth-child(2)')) do
        find('.toggle-bookmark').click
      end

      expect(page).to have_content('Record removed')

      # Add another document to saved records
      within(all('.document').last) do
        find('.toggle-bookmark').click
      end

      expect(page).to have_content('Record saved')

      visit bookmarks_path

      expect(page).to have_css('.active .badge', text: '2')
      expect(page).to have_css('.badge', text: '0')
      within "#documents" do
        expect(page).to have_css("h3.index_title a", count: 2)
      end
    end

    it 'selects and removes all bookmarks' do
      visit search_catalog_path f: { format_hsim: ["Book"] }, view: "default"
      expect(page).to have_css('button[aria-label="Save all records on this page"]')

      click_button 'Save all'
      expect(page).to have_button 'Saved all'
      expect(page).to have_css('button[aria-label="Remove all saved records on this page"]')
      expect(page).to have_text 'Saved 20'
      within '#documents' do
        bookmarks = page.all('.toggle-bookmark')
        expect(bookmarks).to all(have_css('.checked'))
      end

      within(first('.document')) do
        find('.toggle-bookmark').click
      end
      expect(page).to have_text 'Saved 19'

      click_button 'Save all'
      expect(page).to have_text 'Saved 20'

      click_button 'Saved all'
      within '#documents' do
        bookmarks = page.all('.toggle-bookmark')
        expect(bookmarks).to all(have_no_css('.checked'))
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
      expect(page).to have_css('.active .badge', text: '3')
      expect(page).to have_css('.badge', text: '0')
      within "#documents" do
        expect(page).to have_css("article", count: 3)
      end
      # Remove the second document from saved records
      within(first('.document:nth-child(2)')) do
        find('.toggle-bookmark').click
      end

      expect(page).to have_content('Record removed')

      expect(page).to have_css('.active .badge', text: '2')
      expect(page).to have_css('.badge', text: '0')
      within "#documents" do
        expect(page).to have_css("article", count: 2)
      end

      click_button 'Remove all'
      expect(page).to have_text 'Your saved records have been removed'
      expect(page).to have_css('.active .badge', text: '0')
    end
  end

  describe 'bookmarking articles' do
    before do
      stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
    end

    it 'uses the correct document id when saving all records' do
      visit articles_path(q: '"Yet another title for the document"')

      # The bookmark component for articles adds a hidden input with the EDS document ID, which could differ from
      # the record's parameterized ID found in data-document-id. E.g., Original "wq/oeif.zzz" vs parameterized "wq-oeif-zzz".
      expect(page).to have_css('input[name="bookmarks[][document_id]"][value="wq/oeif.zzz"]', visible: :hidden)
      click_button 'Save all'
      expect(page).to have_button('Saved all')
      bookmark = user.bookmarks.find_by(document_id: 'wq/oeif.zzz')
      expect(bookmark).to be_present
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
        select 'Turabian', from: 'Select format'
        expect(page).to have_content '“Some Intersting Papers.” n.d. Imprint Statement.'

        expect(page).to have_link 'In RIS format (Zotero)', href: '/selections.ris'
        expect(page).to have_link 'To RefWorks'
        expect(page).to have_link 'To EndNote', href: '/selections.endnote'
      end
    end
  end

  context 'with no bookmarks' do
    it "renders the page" do
      visit bookmarks_path
      expect(page).to have_css('.bookmark-counter', text: '0')
      expect(page).to have_content "You have no saved records"
    end
  end
end
