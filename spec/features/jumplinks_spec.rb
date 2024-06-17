# frozen_string_literal: true

require 'rails_helper'

describe 'Jump links', :js do
  before do
    allow_any_instance_of(AbstractSearchService).to receive(:search).and_return(response)

    visit quick_search_path
    fill_in 'params-q', with: 'jane stanford'
    click_button 'Search'
  end

  context 'searcher has results' do
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

    scenario 'points to each search module anchor' do
      within '.result-types' do
        expect(page).to have_css(
          'a[href$="#catalog"]',
          text: /Catalog/
        )
        expect(page).to have_css(
          'a[href$="#article"]',
          text: /Articles+/
        )
      end
    end
  end
end
