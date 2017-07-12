require 'spec_helper'

feature 'Article Searching' do
  describe 'Search bar dropdown', js: true do
    scenario 'allows the user to switch to the article search context' do
      stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
      visit root_path

      within '.search-dropdown' do
        click_link 'search catalog'

        expect(page).to have_css('.dropdown-menu', visible: true)

        expect(page).to have_css('li.active a', text: /catalog/)
        expect(page).not_to have_css('li.active a', text: /articles/)

        click_link 'articles'
      end

      expect(page).to have_current_path(article_index_path) # the landing page for Article Search

      within '.search-dropdown' do
        click_link 'search articles'

        expect(page).to have_css('.dropdown-menu', visible: true)

        expect(page).not_to have_css('li.active a', text: /catalog/)
        expect(page).to have_css('li.active a', text: /articles/)
      end
    end
  end

  describe 'articles index page' do
    scenario 'renders home page if no search parameters are present' do
      stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
      visit article_index_path
      expect(page).to have_css('.home-page-column', count: 3)
      expect(page).to have_css('h1', text: /Find journal articles/)
    end

    scenario 'renders results page if search parameters are present' do
      article_search_for('Kittens')

      expect(page).to have_css('h2', text: /\d+ results?/)
      expect(current_url).to match(%r{/article\?.*&q=Kittens})
    end
  end

  scenario 'article records are navigable from search results' do
    stub_article_service(type: :single, docs: [StubArticleService::SAMPLE_RESULTS.first]) # just a single document for the record view

    article_search_for('Kittens')

    within(first('.document')) do
      click_link 'The title of the document'
    end

    expect(page).to have_css('h1', text: 'The title of the document')
    expect(current_url).to match(%r{/article/abc123})
  end

  describe 'breadcrumbs', js: true do
    scenario 'start over button returns users to articles home page' do
      article_search_for('kittens')

      expect(page).to have_css('.appliedFilter', text: /kittens/)

      find('a.btn', text: /Start over/).trigger('click')
      expect(page).to have_current_path(article_index_path)
      expect(page).not_to have_css('.appliedFilter', text: /kittens/)
    end

    scenario 'removing last breadcrumb redirects to articles home' do
      article_search_for('kittens')

      expect(page).to have_css('.appliedFilter', text: /kittens/)

      find(:css, 'a.remove').trigger('click')
      expect(page).not_to have_css('.appliedFilter', text: /kittens/)
      expect(current_url).not_to match(%r{/article\?.*&q=kittens})
    end
  end

  describe 'sidenav mini-map' do
    it 'top/bottom buttons are present in search results' do
      article_search_for('kittens')

      expect(page).to have_button('Top')
      expect(page).to have_button('Bottom')
    end
  end


  it 'displays the appropriate fields in the search' do
    skip 'we need some EDS fixtures'
  end

  def article_search_for(query)
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
    visit article_index_path

    within '.search-form' do
      fill_in 'q', with: query
      if Capybara.current_driver == :poltergeist
        find('#search').trigger('click')
      else
        click_button 'Search'
      end
    end
  end
end
