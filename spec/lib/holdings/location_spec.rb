require "spec_helper"

describe Holdings::Location do
  it "should translate the location code" do
    expect(Holdings::Location.new("STACKS").name).to eq "Stacks"
  end
  it "should identify location level requests" do
    expect(Holdings::Location.new("SSRC-DATA")).to be_location_level_request
  end
end
