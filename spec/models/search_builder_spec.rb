require 'spec_helper'

describe SearchBuilder do
  subject(:search_builder) { described_class.new(scope).with(blacklight_params) }
  let(:blacklight_params) { {} }
  let(:solr_params) { {} }
  let(:scope) { double(blacklight_config: CatalogController.blacklight_config)}

  before do
    # silly hack to avoid refactoring these tests
    allow(blacklight_params).to receive(:dup).and_return(blacklight_params)
  end

  describe "advanced search" do
    it "sets the facet limit to -1 (unlimited)" do
      search_builder.facets_for_advanced_search_form(solr_params)
      expect(solr_params).to include "f.access_facet.facet.limit" => -1,
                                     "f.format_main_ssim.facet.limit" => -1,
                                     "f.format_physical_ssim.facet.limit" => -1,
                                     "f.building_facet.facet.limit" => -1,
                                     "f.language.facet.limit" => -1
    end
  end
end
