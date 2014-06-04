require "spec_helper"

describe ApplicationHelper do
  describe "#data_with_label" do
    let(:temp_doc) {{'key' => 'fudgesicles'}}
    let(:temp_doc_array) {{'key' => ['fudgesicles1','fudgesicles2']}}
    let(:temp_doc_vern) {{'key' => 'fudgesicles', 'vern_key' => 'fudgeyzicles'}}
    let(:temp_doc_vern_array) {{'key' => 'fudgesicles', 'vern_key' => ['fudgeyzicles1','fudgeyzicles2']}}
    describe "get" do
      it "should return a valid label and fields" do
        data = get_data_with_label(temp_doc, "Food:", "key")
        expect(data[:label]).to eq "Food:"
        expect(data[:fields]).to eq ["fudgesicles"]
      end
      it "handle arrays from the index correctly" do
        data = get_data_with_label(temp_doc_array, "Food:", "key")
        expect(data[:fields].length).to eq 2 and
        expect(data[:fields].include?("fudgesicles1")).to be_true
        expect(data[:fields].include?("fudgesicles2")).to be_true
      end
      it "should display the vernacular equivalent for a field if one exists" do
        expect(get_data_with_label(temp_doc_vern, "Food:", "key")[:vernacular]).to eq ["fudgeyzicles"]
      end
      it "should handle vernacular arrays correctly" do
        data = get_data_with_label(temp_doc_vern_array,"Food:","key")[:vernacular]
        expect(data.length).to eq 2
        expect(data.include?("fudgeyzicles1")).to be_true
        expect(data.include?("fudgeyzicles2")).to be_true
      end
      it "should return nil for the vernacular if there is none" do
        expect(get_data_with_label(temp_doc, "Food:", "key")[:vernacular]).to be_nil
      end
      it "should return nil if the field does not exist" do
        expect(get_data_with_label(temp_doc, "Blech:", "not_valid_key")).to be_nil
      end
    end
    describe "link_to" do
      it "should return a valid label and fields" do
        data = link_to_data_with_label(temp_doc, "Food:", "key", {:controller => 'catalog', :action => 'index', :search_field => 'search_author'})
        data[:label].should == "Food:" and
        data[:fields].first.should match(/<a href=.*fudgesicles.*search_field=search_author.*>fudgesicles<\/a>/)
      end
      it "should handle data from the index in an array" do
        fields = link_to_data_with_label(temp_doc_array, "Food:", "key", {:controller => 'catalog', :action => 'index', :search_field => 'search_author'})[:fields]
        fields.include?("<a href=\"/?q=%22fudgesicles1%22&amp;search_field=search_author\">fudgesicles1</a>").should be_true and
        fields.include?("<a href=\"/?q=%22fudgesicles2%22&amp;search_field=search_author\">fudgesicles2</a>").should be_true
      end
      it "should display the linked vernacular equivalent for a field if one exists" do
        link_to_data_with_label(temp_doc_vern, "Food:", "key", {:controller => 'catalog', :action => 'index', :search_field => 'search_author'})[:vernacular].first.should match(/<a href=.*fudgeyzicles.*search_field=search_author.*>fudgeyzicles<\/a>/)
      end
      it "should handle vernacular data from the index in an array" do
        vern = link_to_data_with_label(temp_doc_vern_array, "Food:", "key", {:controller => 'catalog', :action => 'index', :search_field => 'search_author'})[:vernacular]
        vern.include?("<a href=\"/?q=%22fudgeyzicles1%22&amp;search_field=search_author\">fudgeyzicles1</a>").should be_true and
        vern.include?("<a href=\"/?q=%22fudgeyzicles2%22&amp;search_field=search_author\">fudgeyzicles2</a>").should be_true
      end
      it "should return nil if the field does not exist" do
        get_data_with_label(temp_doc, "Blech:", "not_valid_key").should be_nil
      end
    end
  end
  describe "#facet_field_labels" do
    it "should return correct array of labels" do
      @config = Blacklight::Configuration.new do |config|
        config.add_facet_field 'collection', label: "Collection"
        config.add_facet_field 'format', label: 'Format'
      end
      params = HashWithIndifferentAccess.new({f: { collection: ["Good one"], format: ["Book"]}})
      helper.stub(:blacklight_config).and_return(@config)
      expect(helper.facet_field_labels(params)).to eq "Collection, Format"
    end
  end
end
