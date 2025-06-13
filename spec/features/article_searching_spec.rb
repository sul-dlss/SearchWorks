# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Article Searching' do
  describe 'articles index page' do
    scenario 'renders results page if search parameters are present' do
      article_search_for('Kittens')

      expect(page).to have_title 'SearchWorks catalog, Kittens'
      expect(current_url).to match(%r{/articles\?.*&q=Kittens})
    end
  end

  describe 'article search results' do
    scenario 'records are navigable' do
      stub_article_service(type: :single, docs: [StubArticleService::SAMPLE_RESULTS.first]) # just a single document for the record view

      article_search_for('Kittens')

      within(first('.document')) do
        click_link 'The title of the document'
      end

      expect(page).to have_css('h1', text: 'The title of the document')
      expect(current_url).to match(%r{/articles/abc123})
    end

    scenario 'abstracts are truncated', :js do
      long_data = Array.new(100) { |_| 'Lorem ipsum dolor sit amet' }.join(', ')
      document = EdsDocument.new({
                                   id: '123',
                                    eds_title: 'The title of the document',
                                    "Items" => [
                                      {
                                        "Name" => "Abstract", "Data" => long_data
                                      },
                                      {
                                        "Name" => "Subject", "Label" => "Subject Terms", "Group" => "Su",
                                        "Data" => "<searchLink fieldCode=\"SU\" term=\"#{long_data}\">#{long_data}</searchLink>"
                                      }
                                    ],
                                    "RecordInfo" => {
                                      "BibRecord" => {
                                        "BibRelationships" => {
                                          "IsPartOfRelationships" => [{
                                            "NameFull" => long_data
                                          }]
                                        }
                                      }
                                    }
                                 })
      stub_article_service(docs: [document])

      visit articles_path(q: 'Example Search')

      within(first('article')) do
        expect(page).to have_css('dt', text: 'Abstract', visible: :all)
      end
    end

    scenario 'fulltext links are present and have labels' do
      stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
      article_search_for('Kittens')

      expect(page).to have_css('.availability-component .available-online', text: 'Available online')
      expect(page).to have_css('.availability-component  a', text: /^View on detail page/)
      expect(page).to have_css('.availability-component  a', text: /^View full text/)
      expect(page).to have_css('.availability-component  a', text: /^Find full text or request/)
      expect(page).to have_css('.availability-component  a', text: /^View\/download PDF/)
    end
  end

  describe 'breadcrumbs', :js do
    scenario 'start over button returns users to articles new search page' do
      article_search_for('kittens')

      expect(page).to have_css('.applied-filter', text: /kittens/)

      find('a.btn-reset').click
      expect(page).to have_no_css('.applied-filter', text: /kittens/)
    end

    scenario 'removing last breadcrumb redirects to articles home' do
      article_search_for('kittens')

      expect(page).to have_css('.applied-filter', text: /kittens/)

      first(:css, 'a.remove').click
      expect(page).to have_no_css('.applied-filter', text: /kittens/)
      expect(current_url).not_to match(%r{/article\?.*&q=kittens})
    end
  end
end
