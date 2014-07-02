require "spec_helper"

describe FacetsHelper do
  describe "#render_single_facet" do
    before do
      @response = OpenStruct.new(facets: [])
    end
    it "should return nil if there is no facet available" do
      expect(helper.send(:render_single_facet, "not_a_facet")).to be_nil
    end
    it "should render the facet limit when the facet does exist " do
      @response.facets = [OpenStruct.new(name: "this_facet")]
      helper.should_receive(:facet_by_field_name).with("this_facet").and_return("a-facet")
      helper.should_receive(:render_facet_limit).with("a-facet", {}).and_return("a-partial")
      expect(helper.send(:render_single_facet, "this_facet")).to eq "a-partial"
    end
    it "should pass options onto #render_facet_limit" do
      @response.facets = [OpenStruct.new(name: "this_facet")]
      options = {partial: "the-partial-to-render"}
      helper.should_receive(:facet_by_field_name).with("this_facet").and_return("a-facet")
      helper.should_receive(:render_facet_limit).with("a-facet", options).and_return("a-partial")
      expect(helper.send(:render_single_facet, "this_facet", options)).to eq "a-partial"
    end
  end
  describe "#remove_range_param" do
    it "should delete range key" do
      params = {"range" => {test: "123"}, "stuff" => "stuff"}
      expect(helper.remove_range_param("fake_field", params)).to eq ({"stuff" => "stuff"})
    end
    it "should delete search field key if it is dummy range or search" do
      params = {"range" => {test: "123"}, "stuff" => "stuff", "search_field" => "search"}
      expect(helper.remove_range_param("fake_field", params)).to eq ({"stuff" => "stuff"})
      params = {"range" => {test: "123"}, "stuff" => "stuff", "search_field" => "dummy_range"}
      expect(helper.remove_range_param("fake_field", params)).to eq ({"stuff" => "stuff"})
    end
    it "should not delete other search field keys" do
      params = {"range" => {test: "123"}, "stuff" => "stuff", "search_field" => "title"}
      expect(helper.remove_range_param("fake_field", params)).to eq ({"stuff" => "stuff", "search_field" => "title"})
    end
    it "should delete commit key" do
      params = {"range" => {test: "123"}, "stuff" => "stuff", "commit" => "yolo"}
      expect(helper.remove_range_param("fake_field", params)).to eq ({"stuff" => "stuff"})
    end
  end
  describe "#render_resource_icon" do
    it "should render an icon that is in Constants::SUL_ICON" do
      expect(helper.render_resource_icon('Book')).to eq '<span class="sul-icon sul-icon-book-1"></span>'
    end
    it "should not render anything for something not in Constants::SUL_ICON" do
      expect(helper.render_resource_icon('iPad')).to be_nil
    end
  end
end
