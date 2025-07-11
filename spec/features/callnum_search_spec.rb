# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Call num search', :js do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
  end

  let(:object_title) { 'An object' }

  context 'when searching "All fields"' do
    it "shows a search result when the call number has special characters in it" do
      visit search_catalog_path
      fill_in "q", with: "g70.212 .a426 2011:test"
      click_button 'search'
      within "#content" do
        expect(page).to have_css('h3.index_title', text: object_title)
      end
    end
  end

  context 'when searching "Call number"' do
    it "shows a search result when the call number has special characters in it" do
      visit search_catalog_path
      fill_in "q", with: "g70.212 .a426 2011:test"
      select 'Call number', from: 'search_field'
      click_button 'search'
      within "#content" do
        expect(page).to have_css('h3.index_title', text: object_title)
      end
      click_button 'Show all filters'
      click_button 'Call number'
      expect(page).to have_link('Dewey Classification')
      click_button 'Toggle subgroup'
      expect(page).to have_link('000s - Computer Science, Knowledge & Systems')
      within '[role="group"]' do
        click_button 'Toggle subgroup'
      end
      expect(page).to have_link('070s - News Media, Journalism, Publishing')
      click_link object_title
      expect(page).to have_css('h1', text: object_title)
    end
  end

  context 'with SUDOC call numbers' do
    it 'matches the full call number even with whitespace differences' do
      visit search_catalog_path
      fill_in 'q', with: 'Y4 .AP 6/2:S.HRG.98-413'
      select 'Call number', from: 'search_field'
      click_button 'search'
      expect(page).to have_text 'An object'
    end

    it 'matches leading terms of the call number' do
      visit search_catalog_path
      fill_in 'q', with: 'Y4.AP'
      select 'Call number', from: 'search_field'
      click_button 'search'
      expect(page).to have_text 'An object'
    end
  end

  context 'with ALPHANUM call numbers' do
    context 'when the item is from SPEC' do
      it 'matches exact call numbers' do
        visit search_catalog_path
        fill_in 'q', with: 'SC1003A BOX 1'
        select 'Call number', from: 'search_field'
        click_button 'search'
        expect(page).to have_text 'An object'
      end

      it 'matches full call number terms' do
        visit search_catalog_path
        fill_in 'q', with: 'SC1003A'
        select 'Call number', from: 'search_field'
        click_button 'search'
        expect(page).to have_text 'An object'
      end

      it 'does not match a partial call number term' do
        visit search_catalog_path
        fill_in 'q', with: 'SC1003'
        select 'Call number', from: 'search_field'
        click_button 'search'
        expect(page).to have_text 'No results found'
      end
    end

    context 'when the item is not from SPEC' do
      it 'matches searches with at least the first two terms' do
        visit search_catalog_path
        fill_in 'q', with: 'ZVC 12345'
        select 'Call number', from: 'search_field'
        click_button 'search'
        expect(page).to have_text 'An object'
      end

      it 'does not match a search with only the first term' do
        visit search_catalog_path
        fill_in 'q', with: 'ZVC'
        select 'Call number', from: 'search_field'
        click_button 'search'
        expect(page).to have_text 'No results found'
      end

      it 'matches call numbers that look like ETDs' do
        visit search_catalog_path
        fill_in 'q', with: '3781 2009 K'
        select 'Call number', from: 'search_field'
        click_button 'search'
        expect(page).to have_text 'An object'
      end

      it 'matches call numbers that look like CalDocs' do
        visit search_catalog_path
        fill_in 'q', with: 'CALIF E3000  S26 L3 2025'
        select 'Call number', from: 'search_field'
        click_button 'search'
        expect(page).to have_text 'An object'
      end
    end
  end

  context 'with UNDOC call numbers' do
    it 'matches the full call number even with whitespace differences' do
      visit search_catalog_path
      fill_in 'q', with: 'E/ ESCWA/ED/SER. Z/2/2005/2006-2007/2008'
      select 'Call number', from: 'search_field'
      click_button 'search'
      expect(page).to have_text 'An object'
    end

    it 'matches leading terms of the call number' do
      visit search_catalog_path
      fill_in 'q', with: 'E/ESCWA'
      select 'Call number', from: 'search_field'
      click_button 'search'
      expect(page).to have_text 'An object'
    end

    it 'matches call numbers without slashes' do
      visit search_catalog_path
      fill_in 'q', with: 'ICAO'
      select 'Call number', from: 'search_field'
      click_button 'search'
      expect(page).to have_text 'An object'
    end

    it 'does not match only one leading term prior to a slash' do
      visit search_catalog_path
      fill_in 'q', with: 'E'
      select 'Call number', from: 'search_field'
      click_button 'search'
      expect(page).to have_text 'No results found'
    end
  end
end
