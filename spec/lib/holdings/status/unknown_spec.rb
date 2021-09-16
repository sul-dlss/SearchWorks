require "spec_helper"

describe Holdings::Status::Unknown do
  describe "unknown libraries" do
    let(:status) {
      Holdings::Status::Unknown.new(
        OpenStruct.new(library: "LANE-MED")
      )
    }

    it "should identify specific libraries as unknown" do
      expect(status).to be_unknown
    end
  end

  describe "unknown locations" do
    it "should identify specific locations as unknown" do
      Constants::UNKNOWN_LOCS.each do |location|
        expect(Holdings::Status::Unknown.new(OpenStruct.new(home_location: location))).to be_unknown
      end
    end
  end
end
