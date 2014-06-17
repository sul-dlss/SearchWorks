require "spec_helper"

describe Holdings::Location do
  it "should translate the location code" do
    expect(Holdings::Location.new("STACKS").name).to eq "Stacks"
  end
end
