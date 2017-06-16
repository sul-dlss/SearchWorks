require "spec_helper"

describe Holdings::Status::Available do
  it "should identify all force available locations as available" do
    Constants::FORCE_AVAILABLE_CURRENT_LOCS.each do |location|
      expect(described_class.new(instance_double(
        Holdings::Callnumber,
        current_location: Holdings::Location.new(location)
      ))).to be_available
    end
  end
end
