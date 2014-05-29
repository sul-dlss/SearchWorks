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
    let(:mods_field) { OpenStruct.new({label: "test", values: ["hello, there"]}) }
    it "should return correct content" do
      expect(helper.mods_record_field(mods_field)).to have_css("dt", text: "test")
      expect(helper.mods_record_field(mods_field)).to have_css("dd", text: "hello, there")
    end
  end

end
