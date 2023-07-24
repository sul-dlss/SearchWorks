require "spec_helper"

RSpec.describe Holdings::Status::NoncircPage do
  describe "noncirc_page libraries" do
    let(:noncirc_page_libraries) { %w(HV-ARCHIVE RUMSEYMAP SPEC-COLL) }

    it "identifies any items as noncirc_page" do
      noncirc_page_libraries.each do |library|
        expect(Holdings::Status::NoncircPage.new(OpenStruct.new(library:))).to be_noncirc_page
      end
    end
  end

  describe "noncirc_page current locations" do
    subject { Holdings::Status::NoncircPage.new(OpenStruct.new(current_location:)) }

    Constants::FORCE_NONCIRC_CURRENT_LOCS.each do |location|
      context "with #{location}" do
        let(:current_location) { Holdings::Location.new(location, folio_code: nil) }

        it { is_expected.to be_noncirc_page }
      end
    end
  end

  describe "noncirc_page home locations" do
    Constants::NONCIRC_PAGE_LOCS.each do |home_location|
      context "with #{home_location}" do
        subject { Holdings::Status::NoncircPage.new(OpenStruct.new(home_location:)) }

        it { is_expected.to be_noncirc_page }
      end
    end
  end
end
