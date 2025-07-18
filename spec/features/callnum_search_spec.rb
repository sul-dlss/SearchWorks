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
end
