# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FacetOptionsPresenter do
  # let(:view_context) { double('ViewContext') }
  let(:view_context) do
    Class.new do
      include Blacklight::FacetsHelperBehavior
      include Rails.application.routes.url_helpers

      attr_reader :params
      def initialize(params)
        @params = params
      end

      def search_action_path(options = {})
        search_catalog_path(options)
      end

      def search_state
        @search_state ||= Blacklight::SearchState.new(params, blacklight_config)
      end

      def blacklight_config
        ArticlesController.blacklight_config
      end
    end.new(params)
  end
  let(:params) { {} }
  let(:eds_session) do
    double(
      'Eds::Session',
      info: double(
        'Info',
        available_search_criteria: {
          'AvailableLimiters' => [
            { 'Id' => 'FT', 'Label' => 'Facet Label2', 'Type' => 'select', 'Order' => '100' },
            { 'Id' => 'MT', 'Label' => 'Not Displayed', 'Type' => 'not-select', 'Order' => '101' },
            { 'Id' => 'LT', 'Label' => 'Facet Label1', 'Type' => 'select', 'Order' => '10' }
          ]
        }
      )
    )
  end

  subject(:presenter) { described_class.new(params:, context: view_context) }

  describe '#limiters' do
    before do
      expect(presenter).to receive(:eds_session).and_return(eds_session)
    end

    it 'returns only limiters that have a type of "select"' do
      expect(presenter.limiters.length).to eq 2
    end

    it 'sorts the limiters by their "order"' do
      expect(presenter.limiters.first.label).to eq 'Facet Label1'
      expect(presenter.limiters.last.label).to eq 'Facet Label2'
    end
  end

  describe 'FacetOptionsPresenter::Limiter' do
    subject(:limiter) { FacetOptionsPresenter::Limiter.new(limiter_hash, params, view_context) }

    describe '#order' do
      let(:limiter_hash) { { 'Order' => '100' } }

      it 'casts to an integer' do
        expect(limiter.order).to be 100
      end

      context 'when no order is present' do
        let(:limiter_hash) { {} }

        it { expect(limiter.order).to eq 0 }
      end
    end

    describe 'enabled_by_default?' do
      context 'when the "DefaultOn" is "y"' do
        let(:limiter_hash) { { 'DefaultOn' => 'y' } }

        it { expect(limiter).to be_enabled_by_default }
      end

      context 'when the "DefaultOn" is anything else' do
        let(:limiter_hash) { { 'DefaultOn' => 'AnotherValue' } }

        it { expect(limiter).not_to be_enabled_by_default }
      end
    end

    describe '#selected?' do
      let!(:params) { { f: { 'eds_search_limiters_facet' => ['SelectedValue'] } } }

      context 'when the limiter label is in the facet params' do
        let(:limiter_hash) { { 'Label' => 'SelectedValue' } }

        it { expect(limiter).to be_selected }
      end

      context 'when the limiter label is not in the facet params' do
        let(:limiter_hash) { { 'Label' => 'NotASelectedValue' } }

        it { expect(limiter).not_to be_selected }
      end
    end

    describe '#search_url' do
      let(:limiter_hash) { { 'Label' => 'SelectedValue1' } }

      context 'when the limiter is selected' do
        let!(:params) { { f: { 'eds_search_limiters_facet' => %w[SelectedValue1 SelectedValue2] } } }

        it 'it removes the limiter from the URL (and retains other values)' do
          expect(limiter.search_url).not_to include('SelectedValue1')
          expect(limiter.search_url).to include('SelectedValue2')
        end
      end

      context 'when the limiter is not selected' do
        let!(:params) { {} }

        it 'adds the facet to the URL' do
          expect(limiter.search_url).to include('SelectedValue1')
        end
      end
    end
  end
end
