# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searchworks4::InclusiveFacetItemPresenter, type: :presenter do
  subject(:presenter) do
    described_class.new(facet_item, facet_config, view_context, facet_field, search_state)
  end

  let(:facet_item) { instance_double(Blacklight::Solr::Response::Facets::FacetItem) }
  let(:filter_field) { instance_double(Blacklight::SearchState::FilterField, include?: true) }
  let(:facet_config) { Blacklight::Configuration::FacetField.new(key: 'key') }
  let(:facet_field) { instance_double(Blacklight::Solr::Response::Facets::FacetField) }
  let(:view_context) { CatalogController.new.view_context }
  let(:search_state) { instance_double(Blacklight::SearchState, filter: filter_field) }

  describe '#prefix' do
    it 'returns the prefix for inclusive facets' do
      expect(presenter.prefix).to eq('Includes <span class="fw-bold">ANY</span>')
    end
  end
end
