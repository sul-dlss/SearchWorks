require "spec_helper"

describe Holdings::Location do
  it "should translate the location code" do
    expect(Holdings::Location.new("STACKS").name).to eq "Stacks"
  end
  it "should identify location level requests" do
    expect(Holdings::Location.new("SSRC-DATA")).to be_location_level_request
  end
  describe "#present?" do
    let(:location_no_items_or_mhld) {  Holdings::Location.new("STACKS") }
    let(:location_with_items) { Holdings::Location.new("STACKS", ['abc']) }
    it "should be true when there are items" do
      expect(location_with_items).to be_present
    end
    it "should be present when there is an mhld" do
      expect(location_no_items_or_mhld).to_not be_present
      location_no_items_or_mhld.mhld = ['something']
      expect(location_no_items_or_mhld).to be_present
    end
    describe "present_on_index?" do
      let(:mhld) { Holdings::MHLD.new('GREEN -|- STACKS -|- something') }
      let(:library_has_mhld) { Holdings::MHLD.new('GREEN -|- STACKS -|- -|- something -|-') }
      it "should not throw an error on items w/o an mhld" do
        expect(location_no_items_or_mhld).to_not be_present_on_index
      end
      it "should return false unless the public note or latest received are present" do
        location_no_items_or_mhld.mhld = [library_has_mhld]
        expect(location_no_items_or_mhld).to_not be_present_on_index
      end
      it "should return true when an item has a present public note or latest received" do
        location_no_items_or_mhld.mhld = [mhld]
        expect(location_no_items_or_mhld).to be_present_on_index
      end
    end
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
