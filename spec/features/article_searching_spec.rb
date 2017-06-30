require 'spec_helper'

feature 'Article Searching' do
  describe 'Search bar dropdown', js: true do
    scenario 'allows the user to switch to the article search context' do
      visit root_path

      within '.search-dropdown' do
        click_link 'search catalog'

        expect(page).to have_css('.dropdown-menu', visible: true)

        expect(page).to have_css('li.active a', text: /catalog/)
        expect(page).not_to have_css('li.active a', text: /articles/)

        click_link 'articles'
      end

      skip('need to stub out Eds::SearchService') if ENV['CI']
      expect(page).to have_current_path(article_index_path) # the landing page for Article Search

      within '.search-dropdown' do
        click_link 'search articles'

        expect(page).to have_css('.dropdown-menu', visible: true)

        expect(page).not_to have_css('li.active a', text: /catalog/)
        expect(page).to have_css('li.active a', text: /articles/)
      end
    end
  end

  scenario 'when searching w/i the article context we stay in the articles controller' do
    stub_article_service(docs: [SolrDocument.new(id: 'abc123')])
    visit article_index_path

    within '.search-form' do
      fill_in 'q', with: 'Kittens'

      click_button 'Search'
    end

    expect(page).to have_css('h2', text: /\d+ results?/)

    expect(current_url).to match(%r{/article\?.*&q=Kittens})
  end

  scenario 'article records are navigable from search results' do
    results = [
      SolrDocument.new(id: 'abc123', eds_title: 'The title of the document'),
      SolrDocument.new(id: '321cba', eds_title: 'Another title for the document')
    ]
    stub_article_service(docs: results)
    stub_article_service(type: :single, docs: [results.first]) # just a single document for the record view

    visit article_home_path

    within '.search-form' do
      fill_in 'q', with: 'Kittens'

      click_button 'Search'
    end

    within(first('.document')) do
      click_link 'The title of the document'
    end

    expect(page).to have_css('h1', text: 'The title of the document')
    expect(current_url).to match(%r{/article/abc123})
  end
end
