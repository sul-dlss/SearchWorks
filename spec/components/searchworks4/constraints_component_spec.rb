# frozen_string_literal: true

require "rails_helper"

RSpec.describe Searchworks4::ConstraintsComponent, type: :component do
  subject(:component) { described_class.new(**params) }

  before { render_inline(component) }

  let(:params) do
    { search_state: search_state }
  end

  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.add_facet_field :some_facet
      config.add_facet_field '-some_facet', group: 'negative'
    end
  end

  let(:search_state) { Blacklight::SearchState.new(query_params.with_indifferent_access, blacklight_config) }
  let(:query_params) { {} }

  context 'with no constraints' do
    describe '#render?' do
      it 'is false' do
        expect(component.render?).to be false
      end
    end
  end

  context 'with a query' do
    let(:query_params) { { q: 'some query' } }

    it 'renders a start-over link' do
      expect(page).to have_link 'Clear all', href: '/catalog?new=true'
    end

    it 'has a header' do
      expect(page).to have_css('h2', text: 'Search Constraints')
    end

    it 'renders the query' do
      expect(page).to have_css('.applied-filter.constraint', text: 'some query')
        .and(have_no_css('svg'))
    end
  end

  context 'with a facet' do
    let(:query_params) { { f: { some_facet: ['some value'] } } }

    it 'renders the filter' do
      expect(page).to have_css('.constraint-value > .filter-name', text: 'Some Facet')
        .and(have_css('.constraint-value > .filter-value', text: 'some value'))
        .and(have_no_css('svg'))
    end
  end

  context 'with advanced search clause parameters' do
    let(:query_params) do
      { clause: { "0" => { "field" => "search", "op" => "must", "query" => "art tea" }, "1" => { "field" => "search_title", "op" => "should", "query" => "bread roses" } } }
    end

    it 'renders the prefixes for the advanced search clauses' do
      expect(page).to have_css('span.filter-prefix', text: 'Contains ALL')
        .and(have_css('span.filter-prefix', text: 'Contains ANY'))
    end
  end

  context 'with inclusive facet parameters' do
    let(:query_params) { { f_inclusive: { some_facet: %w[Chinese English] } } }

    it 'renders the prefixes for the inclusive facet constraints' do
      expect(page).to have_css('span.filter-prefix', text: 'Includes ANY')
    end
  end

  context 'with negative facet parameters' do
    let(:query_params) { { f: { '-some_facet': ['Chinese'] } } }

    it 'renders the prefixes for the negative facet constraints' do
      expect(page).to have_css('span.filter-prefix', text: 'Excludes ALL')
    end
  end
end
