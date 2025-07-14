# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Zero results" do
  context 'with a catalog search' do
    it "displays the page" do
      visit search_catalog_path(q: 'sdfsda', search_field: 'search_author')
      expect(page).to have_css("h2", text: "Modify your search")
      expect(page).to have_link 'sdfsda'
      expect(page).to have_css('[data-controller="analytics"][data-analytics-category-value="zero-results"]')
      expect(page).to have_css('[data-action="click->analytics#trackLink"]')
    end
  end

  context 'from advanced search' do
    it "displays the page" do
      visit search_catalog_path(op: 'must', clause: { '0' => { query: 'sdfsda', field: 'search_title' } })
      expect(page).to have_link I18n.t('blacklight.search.zero_results.return_to_advanced_search')
    end
  end

  context 'with an article search' do
    before { stub_article_service(docs: []) }

    it 'displays the page' do
      visit articles_path(q: 'Kittens', f: { 'eds_subject_topic_facet' => ['Abc'] }, search_field: 'search')

      within '.zero-results' do
        expect(page).to have_link 'Clear all', href: '/articles?q=Kittens'
        expect(page).to have_link 'Remove constraint Topic: Abc'
      end
    end
  end
end
