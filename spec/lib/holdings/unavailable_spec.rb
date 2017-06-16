require "spec_helper"

describe Holdings::Status::Unavailable do
  describe "unavailable libraries" do
    let(:status) {
      described_class.new(
        instance_double(Holdings::Callnumber, library: "ZOMBIE")
      )
    }
    it "should be unavailable" do
      expect(status).to be_unavailable
    end
  end
  describe "unavailable home locations" do
    it "should be unavailable" do
      Constants::UNAVAILABLE_LOCS.each do |location|
        expect(described_class.new(instance_double(Holdings::Callnumber, home_location: location, library: ''))).to be_unavailable
      end
    end
  end
  describe "unavailable current locations" do
    it "should be unavailable" do
      Constants::UNAVAILABLE_CURRENT_LOCS.each do |location|
        expect(described_class.new(instance_double(Holdings::Callnumber, current_location: Holdings::Location.new(location), library: '', home_location: ''))).to be_unavailable
      end
    end
    it "should handle identify -LOAN properly as unavailable" do
      expect(described_class.new(instance_double(Holdings::Callnumber, current_location: Holdings::Location.new("SOMETHING-LOAN"), library: '', home_location: ''))).to be_unavailable
    end
    it "should not identify SPE-LOAN as unavailable" do
      expect(described_class.new(instance_double(Holdings::Callnumber, current_location: Holdings::Location.new("SPE-LOAN"), library: '', home_location: ''))).to_not be_unavailable
    end
  end
end
