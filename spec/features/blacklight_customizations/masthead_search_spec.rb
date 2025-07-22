# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Masthead search", :js do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
  end

  it 'updates the search form when switching search modes' do
    visit '/catalog?q=1*'
    within '#search-navbar' do
      choose 'Articles+'
    end

    expect(page).to have_css('[name="search_field"] option', text: 'Journal/Source')
    expect(page).to have_css('#q[value="1*"]')
    expect(find('.search-query-form')['action']).to end_with '/articles'

    within '#search-navbar' do
      choose 'Catalog'
    end

    expect(page).to have_css('[name="search_field"] option', text: 'Series')
    expect(find('.search-query-form')['action']).to end_with '/'
  end

  it 'preserves the facet state when switching search modes' do
    visit '/catalog?q=1*&f[format_hsim][]=Book&rows=2'

    expect(page).to have_css('[name="f[format_hsim][]"][value="Book"]', visible: :all)
    within '#search-navbar' do
      choose 'Articles+'
    end

    expect(page).to have_css('[name="search_field"] option', text: 'Journal/Source')
    within '#search-navbar' do
      choose 'Catalog'
    end

    expect(page).to have_css('[name="search_field"] option', text: 'Series')
    expect(page).to have_css('[name="f[format_hsim][]"][value="Book"]', visible: :all)
  end
end
