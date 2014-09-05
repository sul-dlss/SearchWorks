require 'spec_helper'

describe MastheadHelper do
  describe "#render_masthead_partial" do
    let(:page_location) { SearchWorks::PageLocation.new }
    before { helper.stub(:page_location).and_return( page_location ) }
    it "should render partials that exist" do
      page_location.stub(:access_point).and_return("databases")
      expect(helper).to receive(:render).with("catalog/mastheads/databases", {}).and_return('databases-partial')
      expect(render_masthead_partial).to eq "databases-partial"
    end
    it "should return nil for access points that don't have mastheads" do
      page_location.stub(:access_point).and_return("not_an_access_point")
      expect(render_masthead_partial).to be_nil
    end
  end
  describe "#facets_prefix_options" do
    it "should have the correct number of elements" do
      expect(facets_prefix_options.length).to eq 26
    end
    it "should include the necessary options" do
      expect(facets_prefix_options).to include "0-9"
      expect(facets_prefix_options).to include "A"
      expect(facets_prefix_options).to include "Z"
    end
    it "should not contain 'X'" do
      expect(facets_prefix_options).not_to include "X"
    end
  end
  describe '#digital_collections_params_for' do
    it 'should always include "Stanford Digital Repository" in the building facet' do
      expect(digital_collections_params_for).to match /building_facet.*Stanford\+Digital\+Repository/
      expect(digital_collections_params_for('something')).to match /building_facet.*Stanford\+Digital\+Repository/
    end
    it 'should include the given parameter as the format_main_ssim' do
      expect(digital_collections_params_for).to_not match /format_main_ssim/
      expect(digital_collections_params_for('something')).to match /format_main_ssim.*something/
    end
  end
end
