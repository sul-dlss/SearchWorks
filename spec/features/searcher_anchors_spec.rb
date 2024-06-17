# frozen_string_literal: true

require 'rails_helper'

describe 'Searcher Anchor Links', :js do
  before do
    allow_any_instance_of(AbstractSearchService).to receive(:search).and_return(response)

    visit quick_search_path
    fill_in 'params-q', with: 'jane stanford'
    click_button 'Search'
  end

  context 'when a searcher has a total' do
    let(:response) do
      instance_double(
        ArticleSearchService::Response,
        results: [
          instance_double(AbstractSearchService::Result)
        ],
        total: 666_666,
        facets: [],
        highlighted_facet_values: [],
        additional_facet_details: nil
      )
    end

    it 'updates the anchor link with the total count' do
      expect(page).to have_css('.see-all-results', visible: true)
      expect(page).to have_css('#article a', text: /See all 666,666\sarticle\sresults/)
      within '.searcher-anchors' do
        expect(page).to have_css('a', text: 'Articles+ (666,666)')
      end
    end
  end

  context 'when a searcher does not have a total' do
    let(:response) do
      instance_double(
        ArticleSearchService::Response,
        results: [
          instance_double(AbstractSearchService::Result)
        ],
        total: nil,
        facets: [],
        highlighted_facet_values: [],
        additional_facet_details: nil
      )
    end

    it 'does not try to add the total count to the link' do
      expect(page).to have_css('.see-all-results', visible: true)

      within '.searcher-anchors' do
        expect(page).to have_css('a', text: /^Articles\+$/)
      end
    end
  end
end
