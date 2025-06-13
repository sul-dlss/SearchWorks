# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search results', :js do
  context 'when a searcher has a total' do
    let(:response) do
      instance_double(
        ArticleSearchService::Response,
        results: [
          SearchResult.new
        ],
        total: 666_666
      )
    end

    before do
      allow_any_instance_of(AbstractSearchService).to receive(:search).and_return(response)

      visit search_path
      fill_in 'search for', with: 'jane stanford'
      click_button 'Search'
    end

    it 'draws the page' do
      aggregate_failures do
        expect(page).to be_accessible
        expect(page).to have_css('.btn-outline-secondary')
        expect(page).to have_css('#article a', text: /See all 666,666\sarticle\sresults/)
        within '.searcher-anchors' do
          expect(page).to have_link('Articles+', href: '#article').and have_css '#article_count', text: '666,666'
        end
        expect(page).to have_css 'h2', text: 'Guides'
      end
    end
  end

  context 'when a searcher times out' do
    before do
      allow_any_instance_of(ArticleSearchService).to receive(:search).and_raise(HTTP::TimeoutError)
      allow_any_instance_of(AbstractSearchService).to receive(:search).and_return(response)

      visit search_path
      fill_in 'search for', with: 'jane stanford'
      click_button 'Search'
    end

    let(:response) do
      instance_double(
        CatalogSearchService::Response,
        results: [
          SearchResult.new
        ],
        total: 666_666
      )
    end

    it 'draws the page' do
      aggregate_failures do
        expect(page).to have_content 'There was an error retrieving your articles+ results.'
        expect(page).to have_css('.btn-outline-secondary')
        expect(page).to have_link('See all 666,666 catalog results')
      end
    end
  end
end
