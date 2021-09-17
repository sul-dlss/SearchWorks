require "spec_helper"

describe Holdings::Status::NoncircPage do
  describe "noncirc_page libraries" do
    let(:noncirc_page_libraries) { %w(HV-ARCHIVE RUMSEYMAP SPEC-COLL) }

    it "should identify any items as noncirc_page" do
      noncirc_page_libraries.each do |library|
        expect(Holdings::Status::NoncircPage.new(OpenStruct.new(library: library))).to be_noncirc_page
      end
    end
  end

  describe "noncirc_page current locations" do
    it "should identify any items in noncirc_page current locations" do
      Constants::FORCE_NONCIRC_CURRENT_LOCS.each do |location|
        expect(Holdings::Status::NoncircPage.new(OpenStruct.new(current_location: Holdings::Location.new(location)))).to be_noncirc_page
      end
    end
  end

  describe "noncirc_page home locations" do
    it "should identify any items in noncirc_page current locations" do
      Constants::NONCIRC_PAGE_LOCS.each do |location|
        expect(Holdings::Status::NoncircPage.new(OpenStruct.new(home_location: location))).to be_noncirc_page
      end
    end
  end
end
