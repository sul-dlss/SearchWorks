require "spec_helper"

describe Holdings::Location do
  it "should translate the location code" do
    expect(Holdings::Location.new("STACKS").name).to eq "Stacks"
  end
  it "should identify location level requests" do
    expect(Holdings::Location.new("SSRC-DATA")).to be_location_level_request
  end
  describe "enumeration helpers" do
    let(:none) { Holdings::Location.new("STACKS") }
    let(:one) { Holdings::Location.new("STACKS", ["something"]) }
    let(:multiple) { Holdings::Location.new("STACKS", ["something", "else"]) }
    it "should not return true if there are no items" do
      expect(none).to_not be_one_item
      expect(none).to_not be_more_than_one_item
    end
    it "should return true for a single item" do
      expect(one).to be_one_item
      expect(one).to_not be_more_than_one_item
    end
    it "should return true for multiple items" do
      expect(multiple).to_not be_one_item
      expect(multiple).to be_more_than_one_item
    end
  end
end
