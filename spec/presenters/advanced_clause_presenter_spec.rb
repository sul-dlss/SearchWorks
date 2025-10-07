# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdvancedClausePresenter, type: :presenter do
  subject(:presenter) do
    described_class.new('0', params.with_indifferent_access.dig(:clause, '0'), field_config, CatalogController.new.view_context, search_state)
  end

  let(:field_config) { Blacklight::Configuration::NullField.new key: 'some_field' }
  let(:search_state) { Blacklight::SearchState.new(params.with_indifferent_access, Blacklight::Configuration.new) }
  let(:params) { {} }

  context 'with operator must' do
    let(:params) { { clause: { '0' => { query: 'abc def', type: 'all' } } } }

    describe '#prefix' do
      it 'returns the prefix for AND' do
        expect(presenter.prefix).to eq 'Contains <span class="fw-bold">ALL</span>'
      end
    end

    describe '#label' do
      it 'returns a label that equals the query string' do
        expect(presenter.label).to eq 'abc def'
      end
    end
  end

  context 'with operator should' do
    let(:params) { { clause: { '0' => { query: 'abc def', type: 'any' } } } }

    describe '#prefix' do
      it 'returns the prefix for AND' do
        expect(presenter.prefix).to eq 'Contains <span class="fw-bold">ANY</span>'
      end
    end

    describe '#label' do
      it 'returns a label that separates tokens with a comma' do
        expect(presenter.label).to eq 'abc, def'
      end
    end
  end
end
