# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search results', :js do
  before do
    allow_any_instance_of(AbstractSearchService).to receive(:search).and_return(response)

    visit search_path
    fill_in 'search for', with: 'jane stanford'
    click_button 'Search'
  end

  context 'when a searcher has a total' do
    let(:response) do
      instance_double(
        ArticleSearchService::Response,
        results: [
          instance_double(AbstractSearchService::Result)
        ],
        total: 666_666
      )
    end

    it 'draws the page' do
      aggregate_failures do
        expect(page).to be_accessible
        expect(page).to have_css('.btn-outline-secondary')
        expect(page).to have_css('#article a', text: /See all 666,666\sarticle\sresults/)
        within '.searcher-anchors' do
          expect(page).to have_link('Articles+', href: '#article').and have_css '#article_count', text: '666,666'
        end
      end
    end
  end
end
