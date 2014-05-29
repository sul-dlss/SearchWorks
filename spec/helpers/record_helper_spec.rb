require "spec_helper"

describe RecordHelper do
  describe "mods_display_label" do
    it "should return correct label" do
      expect(helper.mods_display_label("test:")).to_not have_content ":"
      expect(helper.mods_display_label("test:")).to have_css("dt", text: "test")
    end
  end

  describe "mods_display_content" do
    it "should return correct content" do
      expect(helper.mods_display_content("hello, there")).to have_css("dd", text: "hello, there")
    end
  end

  describe "mods_record_field" do
    let(:mods_field)  { OpenStruct.new({label: "test", values: ["hello, there"]}) }
    let(:empty_field) { OpenStruct.new({label: "test", values: [""] }) }
    it "should return correct content" do
      expect(helper.mods_record_field(mods_field)).to have_css("dt", text: "test")
      expect(helper.mods_record_field(mods_field)).to have_css("dd", text: "hello, there")
    end
    it "should not print empty labels" do
      expect(helper.mods_record_field(empty_field)).to_not be_present
    end
  end

end
