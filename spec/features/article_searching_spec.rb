# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Article Searching' do
  describe 'articles index page' do
    scenario 'renders results page if search parameters are present' do
      article_search_for('Kittens')

      expect(page).to have_title 'SearchWorks catalog, Kittens'
      expect(page).to have_css('h2', text: /\d+ articles\+ results?/)
      expect(current_url).to match(%r{/articles\?.*&q=Kittens})
    end
  end

  describe 'article search results' do
    scenario 'subjects are not linked' do
      stub_article_service(type: :single, docs: [StubArticleService::SAMPLE_RESULTS.first])
      article_search_for('kittens')
      within '.document-position-1' do
        expect(page).to have_css('dd', text: /Kittens/)
        expect(page).to have_no_link('Kittens')
      end
    end

    scenario 'records are navigable' do
      stub_article_service(type: :single, docs: [StubArticleService::SAMPLE_RESULTS.first]) # just a single document for the record view

      article_search_for('Kittens')

      within(first('.document')) do
        click_link 'The title of the document'
      end

      expect(page).to have_css('h1', text: 'The title of the document')
      expect(current_url).to match(%r{/articles/abc123})
    end

    scenario 'authors, subjects, and abstracts are truncated', :js do
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

      within(first('.document')) do
        expect(page).to have_css('dt', text: /subjects/i)
        expect(page).to have_css('dt', text: /abstract/i)
        expect(page).to have_css('a.responsiveTruncatorToggle', text: 'more...', count: 3)
      end
    end

    scenario 'fulltext links are present and have labels' do
      stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
      article_search_for('Kittens')

      expect(page).to have_css('ul.document-metadata li span.online-label', text: 'Full text')
      expect(page).to have_css('ul.document-metadata li a', text: /^View on detail page/)
      expect(page).to have_css('ul.document-metadata li a', text: /^View full text/)
      expect(page).to have_css('ul.document-metadata li a', text: /^Find full text or request/)
      expect(page).to have_css('ul.document-metadata li a', text: /^View\/download PDF/)
    end
  end

  describe 'breadcrumbs', :js do
    scenario 'start over button returns users to articles home page' do
      article_search_for('kittens')

      expect(page).to have_css('.applied-filter', text: /kittens/)

      find('a.btn-reset').click
      expect(page).to have_current_path(articles_path)
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

  describe 'JSON API' do
    it 'includes the fulltext_link_html data' do
      stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
      visit articles_path(q: 'kittens', format: 'json')
      results = JSON.parse(page.body)
      expect(Capybara.string(results['response']['docs'][0]['fulltext_link_html'])).to have_link('View on detail page')
      expect(Capybara.string(results['response']['docs'][1]['fulltext_link_html'])).to have_link('View full text')

      expect(
        Capybara.string(results['response']['docs'][2]['fulltext_link_html'])
      ).to have_link('Find full text or request')

      expect(Capybara.string(results['response']['docs'][3]['fulltext_link_html'])).to have_link('View/download PDF')
    end
  end
end
