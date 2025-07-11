# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe "#data_with_label" do
    let(:temp_doc) { { 'key' => 'fudgesicles' } }
    let(:temp_doc_array) { { 'key' => ['fudgesicles1', 'fudgesicles2'] } }
    let(:temp_doc_vern) { { 'key' => 'fudgesicles', 'vern_key' => 'fudgeyzicles' } }
    let(:temp_doc_vern_array) { { 'key' => 'fudgesicles', 'vern_key' => ['fudgeyzicles1', 'fudgeyzicles2'] } }

    describe "get" do
      it "returns a valid label and fields" do
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
      it "displays the vernacular equivalent for a field if one exists" do
        expect(get_data_with_label(temp_doc_vern, "Food:", "key")[:vernacular]).to eq ["fudgeyzicles"]
      end
      it "handles vernacular arrays correctly" do
        data = get_data_with_label(temp_doc_vern_array, "Food:", "key")[:vernacular]
        expect(data.length).to eq 2
        expect(data.include?("fudgeyzicles1")).to be_truthy
        expect(data.include?("fudgeyzicles2")).to be_truthy
      end
      it "returns nil for the vernacular if there is none" do
        expect(get_data_with_label(temp_doc, "Food:", "key")[:vernacular]).to be_nil
      end
      it "returns nil if the field does not exist" do
        expect(get_data_with_label(temp_doc, "Blech:", "not_valid_key")).to be_nil
      end
    end

    describe "link_to" do
      it "returns a valid label and fields" do
        data = link_to_data_with_label(temp_doc, "Food:", "key", { controller: 'catalog', action: 'index', search_field: 'search_author' })
        expect(data[:label]).to eq("Food:") and
        expect(data[:fields].first).to match(/<a href=.*fudgesicles.*search_field=search_author.*>fudgesicles<\/a>/)
      end
      it "handles data from the index in an array" do
        fields = link_to_data_with_label(temp_doc_array, "Food:", "key", { controller: 'catalog', action: 'index', search_field: 'search_author' })[:fields]
        expect(fields.include?("<a href=\"/?q=%22fudgesicles1%22&amp;search_field=search_author\">fudgesicles1</a>")).to be_truthy and
        expect(fields.include?("<a href=\"/?q=%22fudgesicles2%22&amp;search_field=search_author\">fudgesicles2</a>")).to be_truthy
      end
      it "displays the linked vernacular equivalent for a field if one exists" do
        actual = link_to_data_with_label(temp_doc_vern, "Food:", "key", { controller: 'catalog', action: 'index', search_field: 'search_author' })
        expect(actual[:vernacular].first).to match(/<a href=.*fudgeyzicles.*search_field=search_author.*>fudgeyzicles<\/a>/)
      end
      it "handles vernacular data from the index in an array" do
        vern = link_to_data_with_label(temp_doc_vern_array, "Food:", "key", { controller: 'catalog', action: 'index', search_field: 'search_author' })[:vernacular]
        expect(vern.include?("<a href=\"/?q=%22fudgeyzicles1%22&amp;search_field=search_author\">fudgeyzicles1</a>")).to be_truthy and
        expect(vern.include?("<a href=\"/?q=%22fudgeyzicles2%22&amp;search_field=search_author\">fudgeyzicles2</a>")).to be_truthy
      end
      it "returns nil if the field does not exist" do
        expect(get_data_with_label(temp_doc, "Blech:", "not_valid_key")).to be_nil
      end
    end
  end

  describe "#active_class_for_current_page" do
    let(:advanced_page) { "advanced" }

    it "is active" do
      helper.request.path = "advanced"
      expect(helper.active_class_for_current_page(advanced_page)).to eq "active"
    end
    it "is not active" do
      helper.request.path = "feedback"
      expect(helper.active_class_for_current_page(advanced_page)).to be_nil
    end
  end

  describe "#from_advanced_search" do
    it "indicates if we are coming from the advanced search form" do
      params[:search_field] = 'advanced'
      expect(helper.from_advanced_search?).to be_truthy
    end
  end
end
