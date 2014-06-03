require "spec_helper"

describe RecordHelper do
  let(:empty_field) { OpenStruct.new({label: "test", values: [""] }) }
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
    it "should return correct content" do
      expect(helper.mods_record_field(mods_field)).to have_css("dt", text: "test")
      expect(helper.mods_record_field(mods_field)).to have_css("dd", text: "hello, there")
    end
    it "should not print empty labels" do
      expect(helper.mods_record_field(empty_field)).to_not be_present
    end
  end
  describe "names" do
    let(:name_field) {
      OpenStruct.new(
        label: "Contributor",
        values: [
          OpenStruct.new(name: "Winefrey, Oprah", roles: ["Host", "Producer"]),
          OpenStruct.new(name: "Kittenz, Emergency")
        ]
      )
    }
    describe "#mods_name_field" do
      it "should join the label and values" do
        name = mods_name_field(name_field)
        expect(name).to match /<dt>Contributor<\/dt>/
        expect(name).to match /<dd><a href.*<\/dd>/
      end
      it "should not print empty labels" do
        expect(mods_name_field(empty_field)).to_not be_present
      end
    end
    describe "#mods_display_name" do
      let(:name) { mods_display_name(name_field.values) }
      it "should link to the name" do
        expect(name).to match /<a href=.*%22Winefrey%2C\+Oprah%22.*>Winefrey, Oprah<\/a>/
        expect(name).to match /<a href=.*%22Kittenz%2C\+Emergency%22.*>Kittenz, Emergency<\/a>/
      end
      it "should link to an author search" do
        expect(name).to match /<a href.*search_field=search_author.*>/
      end
      it "should join the person's roles" do
        expect(name).to match /\(Host, Producer\)/
      end
      it "should not attempt to print empty roles" do
        expect(name).not_to match /\(\)/
      end
    end
  end
end
