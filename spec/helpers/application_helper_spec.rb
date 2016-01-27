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
        expect(data[:fields].include?("fudgesicles1")).to be_truthy
        expect(data[:fields].include?("fudgesicles2")).to be_truthy
      end
      it "should display the vernacular equivalent for a field if one exists" do
        expect(get_data_with_label(temp_doc_vern, "Food:", "key")[:vernacular]).to eq ["fudgeyzicles"]
      end
      it "should handle vernacular arrays correctly" do
        data = get_data_with_label(temp_doc_vern_array,"Food:","key")[:vernacular]
        expect(data.length).to eq 2
        expect(data.include?("fudgeyzicles1")).to be_truthy
        expect(data.include?("fudgeyzicles2")).to be_truthy
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
        expect(data[:label]).to eq("Food:") and
        expect(data[:fields].first).to match(/<a href=.*fudgesicles.*search_field=search_author.*>fudgesicles<\/a>/)
      end
      it "should handle data from the index in an array" do
        fields = link_to_data_with_label(temp_doc_array, "Food:", "key", {:controller => 'catalog', :action => 'index', :search_field => 'search_author'})[:fields]
        expect(fields.include?("<a href=\"/?q=%22fudgesicles1%22&amp;search_field=search_author\">fudgesicles1</a>")).to be_truthy and
        expect(fields.include?("<a href=\"/?q=%22fudgesicles2%22&amp;search_field=search_author\">fudgesicles2</a>")).to be_truthy
      end
      it "should display the linked vernacular equivalent for a field if one exists" do
        expect(link_to_data_with_label(temp_doc_vern, "Food:", "key", {:controller => 'catalog', :action => 'index', :search_field => 'search_author'})[:vernacular].first).to match(/<a href=.*fudgeyzicles.*search_field=search_author.*>fudgeyzicles<\/a>/)
      end
      it "should handle vernacular data from the index in an array" do
        vern = link_to_data_with_label(temp_doc_vern_array, "Food:", "key", {:controller => 'catalog', :action => 'index', :search_field => 'search_author'})[:vernacular]
        expect(vern.include?("<a href=\"/?q=%22fudgeyzicles1%22&amp;search_field=search_author\">fudgeyzicles1</a>")).to be_truthy and
        expect(vern.include?("<a href=\"/?q=%22fudgeyzicles2%22&amp;search_field=search_author\">fudgeyzicles2</a>")).to be_truthy
      end
      it "should return nil if the field does not exist" do
        expect(get_data_with_label(temp_doc, "Blech:", "not_valid_key")).to be_nil
      end
    end
  end
  describe "#active_class_for_current_page" do
    let(:advanced_page) {"advanced"}
    it "should be active" do
      helper.request.path = "advanced"
      expect(helper.active_class_for_current_page(advanced_page)).to eq "active"
    end
    it "should not be active" do
      helper.request.path = "feedback"
      expect(helper.active_class_for_current_page(advanced_page)).to be_nil
    end
  end
  describe "#disabled_class_for_current_page" do
    let(:selections_page) {"selections"}
    it "should be disabled" do
      helper.request.path = "selections"
      expect(helper.disabled_class_for_current_page(selections_page)).to eq "disabled"
    end
    it "should not be disabled" do
      helper.request.path = "feedback"
      expect(helper.active_class_for_current_page(selections_page)).to be_nil
    end
  end
  describe "#disabled_class_for_no_selections" do
    it "should be disabled" do
      expect(helper.disabled_class_for_no_selections(0)).to eq "disabled"
    end
    it "should not be disabled" do
      expect(helper.disabled_class_for_no_selections(1)).to be_nil
    end
  end
end
