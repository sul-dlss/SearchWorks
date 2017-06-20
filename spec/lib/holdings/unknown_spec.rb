require "spec_helper"

describe Holdings::Status::Unknown do
  describe "unknown libraries" do
    let(:status) {
      described_class.new(
        instance_double(Holdings::Callnumber, library: "LANE-MED")
      )
    }
    it "should identify specific libraries as unknown" do
      expect(status).to be_unknown
    end
  end
  describe "unknown locations" do
    it "should identify specific locations as unknown" do
      Constants::UNKNOWN_LOCS.each do |location|
        expect(described_class.new(
          instance_double(Holdings::Callnumber, home_location: location, library: '')
        )).to be_unknown
      end
    end
  end
end
