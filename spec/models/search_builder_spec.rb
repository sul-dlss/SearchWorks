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
  
  describe "#database_prefix_search" do
    before do
      allow(search_builder).to receive(:page_location).and_return(instance_double(SearchWorks::PageLocation, access_point: double(databases?: true)))
    end
    it "should handle 0-9 filters properly" do
      blacklight_params[:prefix] = "0-9"
      search_builder.database_prefix_search(solr_params)
      (0..9).to_a.each do |number|
        expect(solr_params[:q]).to match /title_sort:#{number}\*/
      end
      expect(solr_params[:q]).to match /^title_sort:0\*.*title_sort:9\*$/
    end
    it "should handle alpha filters properly" do
      blacklight_params[:prefix] = "B"
      search_builder.database_prefix_search(solr_params)
      expect(solr_params[:q]).to eq "title_sort:B*"
    end
    it "should AND user supplied queries" do
      blacklight_params[:prefix] = "B"
      blacklight_params[:q] = "My Query"
      search_builder.database_prefix_search(solr_params)
      expect(solr_params[:q]).to eq "title_sort:B* AND My Query"
    end
  end
end
