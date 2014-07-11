require "spec_helper"

describe Holdings::Location do
  it "should translate the location code" do
    expect(Holdings::Location.new("STACKS").name).to eq "Stacks"
  end
  it "should identify location level requests" do
    expect(Holdings::Location.new("SSRC-DATA")).to be_location_level_request
  end
  describe "#mhld" do
    let(:location) {Holdings::Location.new("STACKS")}
    it "should be an accessible attribute" do
      expect(location.mhld).to_not be_present
      location.mhld = "something"
      expect(location.mhld).to be_present
    end
  end
end
