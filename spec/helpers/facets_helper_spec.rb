require "spec_helper"

describe FacetsHelper do
  describe "#render_single_facet" do
    before do
      @response = OpenStruct.new(aggregations: {})
    end

    it "should return nil if there is no facet available" do
      expect(helper.send(:render_single_facet, "not_a_facet")).to be_nil
    end
    it "should render the facet limit when the facet does exist " do
      @response.aggregations = { this_facet: OpenStruct.new(name: "this_facet") }
      expect(helper).to receive(:facet_by_field_name).with("this_facet").and_return("a-facet")
      expect(helper).to receive(:render_facet_limit).with("a-facet", {}).and_return("a-partial")
      expect(helper.send(:render_single_facet, "this_facet")).to eq "a-partial"
    end
    it "should pass options onto #render_facet_limit" do
      @response.aggregations = { this_facet: OpenStruct.new(name: "this_facet") }
      options = { partial: "the-partial-to-render" }
      expect(helper).to receive(:facet_by_field_name).with("this_facet").and_return("a-facet")
      expect(helper).to receive(:render_facet_limit).with("a-facet", options).and_return("a-partial")
      expect(helper.send(:render_single_facet, "this_facet", options)).to eq "a-partial"
    end
  end

  describe "#collapse_home_page_facet?" do
    let(:collapse_facet) { OpenStruct.new(field: 'building_facet') }
    let(:non_collapse_facet) { OpenStruct.new(field: 'other_facet') }

    it "should identify building_facet to be collapsed on the home page" do
      expect(collapse_home_page_facet?(collapse_facet)).to be_truthy
    end
    it "should identify other facets to not be collapsed on the home page" do
      expect(collapse_home_page_facet?(non_collapse_facet)).to be_falsey
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
