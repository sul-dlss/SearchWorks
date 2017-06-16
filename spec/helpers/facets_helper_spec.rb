require "spec_helper"

describe FacetsHelper do
  describe "#render_single_facet" do
    let(:response) { instance_double(Blacklight::Solr::Response) }

    before do
      assign(:response, response)
      expect(response).to receive(:aggregations).and_return(this_facet:
        instance_double(Blacklight::Solr::Response::Facets::FacetField, name: 'this_facet')
      )
    end

    it "should return nil if there is no facet available" do
      expect(helper.send(:render_single_facet, "not_a_facet")).to be_nil
    end
    it "should render the facet limit when the facet does exist " do
      expect(helper).to receive(:facet_by_field_name).with("this_facet").and_return("a-facet")
      expect(helper).to receive(:render_facet_limit).with("a-facet", {}).and_return("a-partial")
      expect(helper.send(:render_single_facet, "this_facet")).to eq "a-partial"
    end
    it "should pass options onto #render_facet_limit" do
      options = {partial: "the-partial-to-render"}
      expect(helper).to receive(:facet_by_field_name).with("this_facet").and_return("a-facet")
      expect(helper).to receive(:render_facet_limit).with("a-facet", options).and_return("a-partial")
      expect(helper.send(:render_single_facet, "this_facet", options)).to eq "a-partial"
    end
  end
  describe "#collapse_home_page_facet?" do
    let(:collapse_facet) { instance_double(Blacklight::Solr::Response::Group, field: 'building_facet') }
    let(:non_collapse_facet) { instance_double(Blacklight::Solr::Response::Group, field: 'other_facet') }
    it "should identify building_facet to be collapsed on the home page" do
      expect(collapse_home_page_facet?(collapse_facet)).to be_truthy
    end
    it "should identify other facets to not be collapsed on the home page" do
      expect(collapse_home_page_facet?(non_collapse_facet)).to be_falsey
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
    it "should not change the original parameters hash" do
      params = {"range" => {test: "123"}, "stuff" => "stuff"}
      expect(helper.remove_range_param("fake_field", params)).to eq ({"stuff" => "stuff"})
      expect(params["range"]).to be_present
    end
  end
  describe "#render_resource_icon" do
    it "should not render anything if format_main_ssim field is not present" do
      expect(helper.render_resource_icon(nil)).to be_nil
    end
    it "should render a book before a database" do
      expect(helper.render_resource_icon(['Database', 'Book'])).to eq '<span class="sul-icon sul-icon-book-1"></span>'
    end
    it "should render an image before a book" do
      expect(helper.render_resource_icon(['Book', 'Image'])).to eq '<span class="sul-icon sul-icon-photos-1"></span>'
    end
    it "should render the first resource type icon" do
      expect(helper.render_resource_icon(['Video', 'Image'])).to eq '<span class="sul-icon sul-icon-film-2"></span>'
    end
    it "should render an icon that is in Constants::SUL_ICON" do
      expect(helper.render_resource_icon(['Book'])).to eq '<span class="sul-icon sul-icon-book-1"></span>'
    end
    it "should not render anything for something not in Constants::SUL_ICON" do
      expect(helper.render_resource_icon(['iPad'])).to be_nil
    end
  end
end
