# frozen_string_literal: true

require 'rails_helper'

describe 'search/_highlighted_facet' do
  let(:facet1) do
    instance_double(
      AbstractSearchService::HighlightedFacetItem, label: 'Abc', value: 'Abc', hits: 20, query_url: 'query1'
    )
  end

  let(:facet2) do
    instance_double(
      AbstractSearchService::HighlightedFacetItem, label: 'Cba', value: 'Cba', hits: 10, query_url: 'query2'
    )
  end

  before do
    without_partial_double_verification do
      allow(view).to receive(:searcher).and_return(searcher)
    end

    render
  end

  context 'when there are no facet values' do
    let(:searcher) do
      instance_double(
        QuickSearch::ArticleSearcher,
        search: double(highlighted_facet_values: [])
      )
    end

    it { expect(rendered).to be_blank }
  end

  context 'when there are facet values' do
    let(:searcher) do
      instance_double(
        QuickSearch::ArticleSearcher,
        search: double(highlighted_facet_values: [facet1, facet2])
      )
    end

    it 'renders a link for each facet value returned' do
      within '.highlighted-facet' do
        expect(rendered).to have_link('Abc (20)', href: 'query1')
        expect(rendered).to have_link('Cba (10)', href: 'query2')
      end
    end
  end
end
