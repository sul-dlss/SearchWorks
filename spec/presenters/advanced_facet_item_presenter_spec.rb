# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdvancedFacetItemPresenter, type: :presenter do
  subject(:presenter) do
    described_class.new(group, facet_item, facet_config, view_context, facet_field, search_state)
  end

  let(:facet_config) { Blacklight::Configuration::FacetField.new(key: 'key') }
  let(:facet_field) { instance_double(Blacklight::Solr::Response::Facets::FacetField) }
  let(:view_context) { CatalogController.new.view_context }

  let(:group) { %w[a b c] }
  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.add_facet_field :key
    end
  end
  let(:search_state) { Blacklight::SearchState.new(params, blacklight_config) }
  let(:params) { { f_inclusive: { key: group } } }

  describe '#selected?' do
    context 'when facet item value is included in group' do
      let(:facet_item) { Blacklight::Solr::Response::Facets::FacetItem.new(value: 'a') }

      it 'uses facet item value for selection' do
        expect(presenter.selected?).to be true
      end
    end

    context 'when facet item value is not included in group' do
      let(:facet_item) { Blacklight::Solr::Response::Facets::FacetItem.new(value: 'd') }

      it 'returns false for selection' do
        expect(presenter.selected?).to be false
      end
    end
  end
end
