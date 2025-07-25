# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searchworks4::FacetSearchComponent, type: :component do
  before do
    render_inline(described_class.new(facet_field: facet_field))
  end

  let(:facet_config) { Blacklight::Configuration::NullField.new(key: 'field', item_component: Blacklight::Facets::ItemComponent, item_presenter: Blacklight::FacetItemPresenter) }

  let(:paginator) do
    instance_double(Blacklight::FacetPaginator, items: [
      Blacklight::Solr::Response::Facets::FacetItem.new(value: 'a', label: 'a', hits: 10),
      Blacklight::Solr::Response::Facets::FacetItem.new(value: 'b', label: 'b', hits: 20),
      Blacklight::Solr::Response::Facets::FacetItem.new(value: 'c', label: 'c', hits: 30)
    ])
  end

  context 'with inclusive facets' do
    let(:facet_field) do
      instance_double(
        Blacklight::FacetFieldPresenter,
        paginator: paginator,
        facet_field: facet_config,
        key: 'field',
        label: 'Field',
        active?: false,
        collapsed?: false,
        modal_path: nil,
        values: [%w[a b]],
        search_state: search_state
      )
    end

    let(:blacklight_config) do
      Blacklight::Configuration.new.configure do |config|
        config.add_facet_field :field
      end
    end
    let(:search_state) { Blacklight::SearchState.new(params.with_indifferent_access, blacklight_config) }
    let(:params) { { f_inclusive: { field: %w[a b] } } }

    it 'renders heading for inclusive constraints' do
      expect(page).to have_css('span.advanced-facet-heading', text: 'Includes ANY')
    end
  end
end
