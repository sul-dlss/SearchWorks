# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchBuilder do
  subject(:search_builder) { described_class.new(scope).with(blacklight_params) }

  let(:blacklight_params) { {} }
  let(:solr_params) { {} }
  let(:action_name) { 'index'}
  let(:scope) { double(blacklight_config: CatalogController.blacklight_config, search_state_class: nil, action_name:, controller_name: 'catalog') }

  before do
    # silly hack to avoid refactoring these tests
    allow(blacklight_params).to receive(:dup).and_return(blacklight_params)
  end

  describe "#database_prefix_search" do
    before do
      allow(search_builder).to receive(:page_location).and_return(instance_double(PageLocation, databases?: true))
    end

    it "should handle 0-9 filters properly" do
      search_builder.with(prefix: '0-9').database_prefix_search(solr_params)
      expect(solr_params[:fq]).to include("title_sort:/[0-9].*/")
    end
    it "should handle alpha filters properly" do
      search_builder.with(prefix: 'b').database_prefix_search(solr_params)
      expect(solr_params[:fq]).to include("title_sort:/[b].*/")
    end
    it "should do nothing if prefix param is invalid" do
      search_builder.with(prefix: '*').database_prefix_search(solr_params)
      expect(solr_params[:fq]).to be_nil
    end
  end

  describe "advanced search" do
    let(:action_name) { 'advanced_search' }

    it "sets the facet limit to -1 (unlimited)" do
      search_builder.facets_for_advanced_search_form(solr_params)
      expect(solr_params).to include "f.access_facet.facet.limit" => -1,
                                     "f.format_main_ssim.facet.limit" => -1,
                                     "f.format_physical_ssim.facet.limit" => -1,
                                     "f.building_facet.facet.limit" => -1,
                                     "f.language.facet.limit" => -1
    end
  end

  describe '#consolidate_home_page_params' do
    context 'on the home page' do
      it 'overrides solr parameters to just the things the home page needs' do
        solr_params = { 'facet.field' => ['some garbage'], 'rows' => 50 }
        search_builder.consolidate_home_page_params(solr_params)
        expect(solr_params).to include 'facet.field' => ['access_facet', 'format_main_ssim', 'building_facet', 'language'], 'rows' => 0
      end
    end

    context 'with search parameters' do
      let(:blacklight_params) { { q: 'x' } }

      it 'does nothing' do
        solr_params = { 'facet.field' => ['some garbage'], 'rows' => 50 }
        search_builder.consolidate_home_page_params(solr_params)
        expect(solr_params).to include 'facet.field' => ['some garbage'], 'rows' => 50
      end
    end
  end
end
